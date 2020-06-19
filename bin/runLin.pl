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
use Alerting;
use Data::Dumper;
use DateTime;
use DateTime::Format::Strptime;

# FATAL, ERROR, WARN, INFO, DEBUG, and TRACE 
use Log::Log4perl qw(:levels);
my $logger = get_logger();

#
# Setup signal handlers so that we have time to cleanup before shutting down
my $run = 1;
$SIG{TERM} = sub { $logger->warn("Caught SIGTERM:  exiting gracefully"); $run = 0; };
$SIG{INT} = sub { $logger->warn("Caught SIGINT:  exiting gracefully"); $run = 0; };

main();

sub main {
    $App::Daemon::logfile    = $MoTMa::Application::basePath."var/log/motma.log";
    $App::Daemon::pidfile    = $MoTMa::Application::basePath."var/run/motma.pid";
    $App::Daemon::kill_retries = 30;
    $App::Daemon::l4p_conf   = $MoTMa::Application::basePath."etc/motma.l4p";
    $App::Daemon::background = 1;
    $App::Daemon::as_user    = "nagios";
    $App::Daemon::as_group   = "nagios";
    $App::Daemon::appname    = "MoTMa";

    # Daemonize the Application
    daemonize();

    my $helpDesk = new HelpDesk();
    my $ticketSystem = new Ticketing();
    my $monitorSystem = new Monitoring();
    my $alert = new Alerting();
    my $serviceTicket;
    my $updateTicket;
    my $workingLoop = 0;

    $logger->trace("trace");
    $logger->debug("debug");
    $logger->info("info");
    $logger->warn("warn");
    $logger->error("error");
    $logger->fatal("fatal");
    
    while ($run) {
        $workingLoop++;
        # Get new events
        $logger->info( "Check for new Events" );
        my $events = $helpDesk->getNewEvents();
        # Process the new events ( Create Ticket or add event to existing ticket )
        foreach my $idevent (sort keys(%$events)) {
            $logger->info("--- NEW EVENT [$events->{$idevent}{created}] $events->{$idevent}{host}/$events->{$idevent}{service} ---");
            
            # Create Ticket
            #   $idticket: id of ticket from helpdeskdb
            #   $itsmTicket: Ticketing System Number
            #   $updateTicket: Do we have to update this ticket?
            my ($idticket, $itsmTicket, $updateTicket) = $helpDesk->createTicket($idevent,$events);
            if ($idticket) {
                if ($updateTicket == 1) {
                    # helpdesk ticket needs update (we have already a ticket for this host/service)
                    $helpDesk->updateTicket($idticket, $itsmTicket, 'UPDATE');
                }
                elsif ($updateTicket == 2) {
                    $logger->info("NEW but we have now at least two events in this ticket");
                }
                else {
                    $logger->info("NEW ticket created");
                }
            }
            else {
                # Internal Problem - Ticket not created
                $logger->fatal("FATAL - Ticket not created because of internal Problem - Check your Database");
                $alert->save("FATAL - Ticket not created because of internal Problem - Check your Database",
                    Dumper($events->{$idevent}));
                
                # exit loop and end MoTMa
                $run = 0;
                last;
            }
        }
        
        # Check if stop of daemon is requested
        last if not $run;
        
        # Get new tickets and create incident on Ticketing System
        $logger->info( "Check for \"NEW\" Tickets" );
        my $tickets = $helpDesk->getTicketsByTicketState('NEW');
        # Prepare alerting
        $Alerting::now = DateTime->now->set_time_zone(DateTime::TimeZone::Local->TimeZone());
        # Process the new tickets and create them on ticketing system
        foreach my $idticket (keys %$tickets) {
            # Get the Parameters
            my %test = split(/[=;]/, $tickets->{$idticket}{parameters});
            
            # Check if we have host or service events
            $serviceTicket = 1;
            if ($tickets->{$idticket}{service} eq '') {
                $serviceTicket = 0;
            }

            # Prepare alerting
            my $parser = DateTime::Format::Strptime->new( pattern => '%Y-%m-%d %H:%M:%S' );
            $Alerting::ticketCreated = $parser->parse_datetime($tickets->{$idticket}{created});
            
            # Send Ticket to Ticketing System
            my $incidentId = $ticketSystem->create(\%test, $idticket, $serviceTicket);
            if ($incidentId ne 0) {
                if ($incidentId eq 1) {
                    # There is no Incident ID in the create response - we will try later to get the Incident ID
                    $helpDesk->updateTicket($idticket, '', 'PROCESSING');
                }
                else {
                    $helpDesk->updateTicket($idticket, $incidentId, 'WORKING');
                }
            }
            else {
                $logger->warn("Please Check your Ticketing System - its probably not running!");
                $logger->trace("Now: ".$Alerting::now." Ticketcreated: ".$Alerting::ticketCreated);
            }
        }
        
        # Check if stop of daemon is requested
        last if not $run;

        # Get updatable tickets and send data to ITSM System
        $logger->info( "Check for \"UPDATE\" Tickets" );
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

            my $ticketNumber = '';
            if ($updates->{$idticket}{ticketnumber} eq '') {
                $ticketNumber = $ticketSystem->getTicketNumber($idticket);
            }
            else {
                $ticketNumber = $updates->{$idticket}{ticketnumber};
            }

            if ($ticketNumber eq '') {
                $logger->warn("!!!!!!!! ITSM TICKET $idticket not found !!!!!!!!!".Dumper($updates->{$idticket}));
                # try in next round
            }
            else {
                # Close Ticket on ITSM Ticketing if in Good state
                if ($MoTMa::Application::autoClose && $events->{$idevents}{monitoringstatus} =~ /^OK$|^UP$/ ) {
                    $logger->info("ITSM Ticket = $ticketNumber idticket = $idticket serviceTicket = $serviceTicket CLOSED");

                    # Try to close ticket
                    # When successfuly update helpdesk to CLOSED
                    if ($ticketSystem->update(\%eventDetail, $idticket, 1, $serviceTicket, $ticketNumber)) {
                        $helpDesk->updateTicket($idticket, $ticketNumber, 'CLOSED');
                    }
                }
                # Only update Ticket
                elsif ($MoTMa::Application::updateTicket) {
                    $helpDesk->updateTicket($idticket, $ticketNumber, 'WORKING');
                    $ticketSystem->update(\%eventDetail, $idticket, 0, $serviceTicket, $ticketNumber);
                }
                else {
                    $helpDesk->updateTicket($idticket, $ticketNumber, 'WORKING');
                }
            }
        }

        # Check if stop of process is requested
        last if not $run;
        
        # Get incidents in progress
        $logger->info( "Check for \"PROCESSING\" Tickets" );
        my $incidents = $helpDesk->getTicketsByTicketState('PROCESSING');
        # Get information from ITSM and update tickets
        foreach my $idticket (keys %$incidents) {
            # Get Ticket ID
            my $ticketNumber = $ticketSystem->getTicketNumber($idticket);

            if ($ticketNumber ne '') {
                $helpDesk->updateTicket($idticket, $ticketNumber, 'WORKING');
            }
            else {
                $logger->warn( "Ticket not found" );
                # TODO: TRACE HOW often its checked
            }
        }

        # Check if stop of daemon is requested
        last if not $run;

        if ($workingLoop >= $MoTMa::Application::updateWorking) {
            # Get incidents supporters should work on
            $logger->info( "Check for \"WORKING\" Tickets" );
            $incidents = $helpDesk->getTicketsByTicketState('WORKING');
            # Get information from ITSM and update tickets
            foreach my $idticket (keys %$incidents) {
                # Get Ticket
                my $itsmTicket = $ticketSystem->getTicket($idticket, '');
                $logger->debug("IncidentDetail: ".Dumper($itsmTicket));
                if (defined($itsmTicket->{'incidentnumber'})) {
                    if ( grep {$_ eq $itsmTicket->{'status'}} @MoTMa::Application::ticketClosedState) {
                        $helpDesk->updateTicket($idticket, $itsmTicket->{'incidentnumber'}, 'CLOSED');
                        $logger->trace("Found Remedy Ticket: ".$itsmTicket->{'incidentnumber'}." with status: ".
                            $itsmTicket->{'status'}." - WE close it...");
                    }
                }
                else {
                    $logger->error( "Did not find a 'incidentnumber' for idhelpdesk: $idticket" );
                }
            }

            # Reset Working Loop to 0
            $workingLoop = 0;
        }

        # wee want run every
        sleep $MoTMa::Application::loopInterval if $run;
    }

    $logger->info( "Shutting down motma application" );
}