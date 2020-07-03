#!/usr/bin/perl
# ------------------------------------------------------------------------------
# Filename:     NoMa.pm
# Author:       Andreas Wenger, RealStuff Informatik AG (http://www.realstuff.ch)
# Since:        0.2
# Abstract:
#
# ------------------------------------------------------------------------------
# Edition history:
#
# 2020/05/11    awe     Initial version
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
# Copyright (c) 2020 RealStuff Informatik AG (www.realstuff.ch).
#
package NoMa;

use strict;
use warnings;
use DBI;
use Data::Dumper;
use MoTMa::Application;
use POSIX qw/strftime/;
use Log::Log4perl qw(:easy);

our $VERSION = $MoTMa::Application::VERSION;

our ($host, $hostAlias, $hostAddress, $service, $ticketState, $ticketOutput, $ticketLongOutput, $duration,
     $hostgroupName, $hostgroupAlias, $submitDate, $submitLongDate, $notificationType);

my $logger = get_logger();

# Preloaded methods go here.
sub new {
    my $class = shift;
    my $self = {};
    
    bless $self, $class;
    return $self;
}

sub DESTROY {
    
}

sub getEventDetail {
    my $self           = shift;
    my $ticket         = shift;
    my $serviceTicket  = shift;
    
    # my %ticket;
    $host              = $ticket->{'host'};
    $hostAlias         = $ticket->{'host_aliase'};
    $hostAddress       = $ticket->{'host_address'};
    if ($serviceTicket) {
        $service         = $ticket->{'service'};
        $ticketState      = $ticket->{'status'};
        $ticketOutput     = $ticket->{'output'};
        # $ticketLongOutput = $ticket->{'???'};
        # $duration          = $ticket->{'???'};
    }
    else {
        $service         = "";
        $ticketState      = $ticket->{'status'};
        $ticketOutput     = $ticket->{'output'};
        # $ticketLongOutput = $ticket->{'???'};
        # $duration          = $ticket->{'???'};
    }
    # $hostgroupName     = join('',grep(!/^z{1,2}?_/, split(",", $ticket->{'NAGIOS_HOSTGROUPNAMES'})));
    # $hostgroupAlias    = $ticket->{'NAGIOS_HOSTGROUPALIAS'};
    $submitDate        = $ticket->{'datetime'};
    $submitLongDate    = $ticket->{'datetimes'};
    # $notificationType  = $ticket->{'NAGIOS_NOTIFICATIONTYPE'};
}

sub getIncidentDetails {
    my $self           = shift;
    my $ticket         = shift;
    my $serviceTicket  = shift;
    my $incidentDescription; 
    my $incidentDetail;
    
    $self->getEventDetail($ticket, $serviceTicket);

    # incident
    if ($serviceTicket) {
        $incidentDescription = substr "$host: $service: $ticketState",0,100;
    }
    else {
        $incidentDescription = substr "$host: $ticketState",0,100;
    }
    my $message          = $incidentDetail;
    my $incidentPriority = "MEDIUM";

    # Check if System is Produktion
    if ( $hostAlias =~ "m/^Produ|^produ/" ) {
        $incidentPriority = "High";
    }

    # The default Productname
    my $productName = "";
    $productName = "GroundWork Services";
    # The default Customer
    my $customerName = "";
    my $companyName = "";
    $companyName = "RealStuff Informatik AG";

    # worklog
    my $worklogDescription = $incidentDescription;
    my $worklogDetail      = "***** GroundWork $submitLongDate ****
Host:     $host
";
    if ($serviceTicket) {
        $worklogDetail .= "Service:  $service";
    }
    $worklogDetail .= "
Address:  $hostAddress
State:    $ticketState

Info:     $ticketOutput

$ticketLongOutput

Date:     $submitDate
Link:     $MoTMa::Application::monitoringStatusPage$host&amp;service=$service";

    $incidentDetail = $worklogDetail;

    $logger->trace(
        "Got following Ticket Details:
               Incident-Description : $incidentDescription
               Incident-Detail: -> see worklog
               Incident-Priority: $incidentPriority
               Worklog: $worklogDetail");
  
    return ($incidentPriority, $incidentDescription, $incidentDetail, $customerName, $productName,$companyName,
        $worklogDescription, $worklogDetail);
}


1;
__END__

=head1 NAME

NoMa - Perl module implementing the monitoring driver "NoMa" for MoTMa

=head1 SYNOPSIS

  use NoMa;

=head1 DESCRIPTION

This is the monitoring driver for nagios.

=head2 EXPORT

None by default.



=head1 SEE ALSO

=head1 AUTHOR

Andreas Wenger, E<lt>andreas.wenger@realstuff.chE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2020 by Andreas Wenger

This library is free software; you can redistribute it and/or modify
it under the same terms as LGP

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public License as
published by the Free Software Foundation; either version 2 of the
License, or (at your option) any later version.  You may also can
redistribute it and/or modify it under the terms of the Perl
Artistic License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received copies of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.


=cut
