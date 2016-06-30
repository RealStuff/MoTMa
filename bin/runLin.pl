#!/usr/local/groundwork/perl/bin/perl
# ------------------------------------------------------------------------------
# Filename:     runLin.pl
# Author:       Andreas Wenger, RealStuff Informatik AG (http://www.realstuff.ch)
# Since:        0.1
# Abstract:
#
# ------------------------------------------------------------------------------
# Edition history:
#
# 2014/05/11    awe     Initial version
#
# ******************************************************************************
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program; if not, write to the
#    Free Software Foundation, Inc.
#    59 Temple Place, Suite 330
#    Boston, MA 02111-1307 USA
# ******************************************************************************
#
#
# Copyright (c) 2014 RealStuff Informatik AG (www.realstuff.ch).
#

BEGIN {
    use Cwd 'abs_path';
    use File::Basename;
    $basePath = dirname(abs_path($0));
    $basePath =~ s/bin$//;
}

use lib $basePath.'lib/';

use strict;
use warnings;
use App::Daemon qw(daemonize);
use Cwd;
use File::Spec;
use Log::Log4perl qw(:easy);
use MoTMa::Application;
use HelpDesk;
use Ticketing;
use Monitoring;
use Data::Dumper;

main();

sub main {
    $App::Daemon::logfile    = "/opt/motma/var/log/motma.log";
    $App::Daemon::pidfile    = "/opt/motma/var/run/motma.pid";
    #$App::Daemon::l4p_conf   = "myconf.l4p";
    $App::Daemon::background = 1;
    $App::Daemon::as_user    = "nagios";
    $App::Daemon::as_group   = "nagios";

    use Log::Log4perl qw(:levels);
    $App::Daemon::loglevel   = $DEBUG;

    # Daemonize the Application
    daemonize();

    my $logger = get_logger();
    my $helpDesk = new HelpDesk();
    my $ticketSystem = new Ticketing();
    my $monitorSystem = new Monitoring();
    my $serviceTicket;
    my $updateTicket;
    
    while (1) {
        $logger->info( "Check for new Events" );
        
        # Get new events
        my $events = $helpDesk->getNewEvents();
        # Process the new events ( Create Ticket or add event to existing ticket )
        foreach my $idevent (keys %$events) {
            $logger->info("| $events->{$idevent}{host} | $events->{$idevent}{service} |");
            
            # CHECK IF THIS IS A NEW EVENT!
            #  --> YES: NICHTS
            #  --> NO:
            #       UPDATE?
            #           --> YES: UPDATE INCIDENT
            #           --> NO: MACHE NICHTS
            #       AUTOCLOSE:
            #           --> YES: CLOSE INCIDENT
            #           --> NO: MACHE NICHTS
            my ($idticket, $itsmTicket, $updateTicket) = $helpDesk->createTicket($idevent,$events);
            print "idticket: $idticket, itsmTicket: $itsmTicket\n";
            if ($idticket) {
                if ($updateTicket) {
                    $helpDesk->updateTicket($idticket, $itsmTicket, 'UPDATE');
                }
            }
            else {
                print "ERROR - Kein Ticket erstellt oder Fehler beim schreiben in die Datenbank\n";
            }
        }
        sleep 3;
        
        # Get new tickets and create incident on ITSM System
        my $tickets = $helpDesk->getTicketsByTicketState('NEW');
        # Process the new tickets and create them on ticketing system
        foreach my $idticket (keys %$tickets) {
            # print "TicketStatus: '".$tickets->{$idticket}{ticketstatus}."' Ticketnumber: '".$tickets->{$idticket}{ticketnumber}."'\n";
            
            # Get the Parameters
            my %test = split(/[=;]/, $tickets->{$idticket}{parameters});
            # print "HOST: ".$test{NAGIOS_HOSTNAME}." SERVICE: ".$test{NAGIOS_SERVICEDESC}."\n";
            
            # Check if we have host or service events
            $serviceTicket = 1;
            if ($tickets->{$idticket}{service} eq '') {
                $serviceTicket = 0;
            }
            
            # Send Ticket to Ticketing System
            if ($ticketSystem->create(\%test, $idticket, $serviceTicket)) {
                    # print "Ticket created $idticket\n";
                    $helpDesk->updateTicket($idticket, '', 'PROCESSING');
            }
            else {
                print "Please Check your Ticketing System\n";
            }
        }
        sleep 3;

        # Get updatable tickets and send data to ITSM System
        my $updates = $helpDesk->getTicketsByTicketState("UPDATE");
        # Process the updatable tickets and update them on ticketing system
        foreach my $idticket (keys %$updates) {

           
            # Get the last event for this ticket
            my $events = $helpDesk->getLastEventFromTicket($idticket);
            my ($idevents) = keys %$events;

            # Get the Parameters
            my %eventDetail = split(/[=;]/, $events->{$idevents}{parameters});

             # Check if we have host or service events
            $serviceTicket = 1;
            if ($events->{$idevents}{service} eq '' || not defined $events->{$idevents}{service}) {
                $serviceTicket = 0;
            }
            
            # if ($MoTMa::Application::updateTicket) {
            #     print "--------Update--------\n";
            #     # my $ticket          = shift;
            #     # my $idTicket        = shift;
            #     # my $serviceTicket   = shift;
            #     $ticketSystem->update(\%eventDetail, $idticket, 0, $serviceTicket);
            # }
            if ($MoTMa::Application::autoClose) {
                my $itsmTicket = '';
                if (not defined $updates->{$idticket}{ticketnumber}) {
                    $itsmTicket = $ticketSystem->getTicketNumber($idticket);
                    # print "ITSM Ticket geholt -- \n";
                }
                else {
                    $itsmTicket = $updates->{$idticket}{ticketnumber};
                }

                print "ITSM Ticket = $itsmTicket idticket = $idticket serviceTicket = $serviceTicket\n";
                $helpDesk->updateTicket($idticket, $itsmTicket, 'CLOSED');
                $ticketSystem->update(\%eventDetail, $idticket, 1, $serviceTicket);
                print "------AutoClose-------\n";
            }
        }
        sleep 3;
        
        # Get incidents in progress
        my $incidents = $helpDesk->getTicketsByTicketState('PROCESSING');
        # Get information from ITSM and update tickets
        foreach my $idticket (keys %$incidents) {
            # Get Ticket ID
            my $ticketId = $ticketSystem->getTicketNumber($idticket);

            if ($ticketId ne '') {
                $helpDesk->updateTicket($idticket, $ticketId, 'WORKING');
            }
            else {
                print "No Ticket found";
                #   TRACE HOW often its checked
            }
            
        #     # if () {
        #     #     print "Ticket updated\n";
        #     # }
        }
        sleep 3;
    }
}