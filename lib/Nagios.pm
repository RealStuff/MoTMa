package Nagios;

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
    $host              = $ticket->{'NAGIOS_HOSTNAME'};
    $hostAlias         = $ticket->{'NAGIOS_HOSTALIAS'};
    $hostAddress       = $ticket->{'NAGIOS_HOSTADDRESS'};
    if ($serviceTicket) {
        $service         = $ticket->{'NAGIOS_SERVICEDESC'};
        $ticketState      = $ticket->{'NAGIOS_SERVICESTATE'};
        $ticketOutput     = $ticket->{'NAGIOS_SERVICEOUTPUT'};
        $ticketLongOutput = $ticket->{'NAGIOS_LONGSERVICEOUTPUT'};
        $duration          = $ticket->{'NAGIOS_SERVICEDURATION'};
    }
    else {
        $service         = "";
        $ticketState      = $ticket->{'NAGIOS_HOSTSTATE'};
        $ticketOutput     = $ticket->{'NAGIOS_HOSTOUTPUT'};
        $ticketLongOutput = $ticket->{'NAGIOS_LONGHOSTOUTPUT'};
        $duration          = $ticket->{'NAGIOS_HOSTDURATION'};
    }
    $hostgroupName     = join('',grep(!/^z{1,2}?_/, split(",", $ticket->{'NAGIOS_HOSTGROUPNAMES'})));
    $hostgroupAlias    = $ticket->{'NAGIOS_HOSTGROUPALIAS'};
    $submitDate        = $ticket->{'NAGIOS_SHORTDATETIME'};
    $submitLongDate    = $ticket->{'NAGIOS_LONGDATETIME'};
    $notificationType  = $ticket->{'NAGIOS_NOTIFICATIONTYPE'};
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
        $incidentDescription = substr "Kunde $hostgroupName $service/$host - Service $ticketState",0,100;
    }
    else {
        $incidentDescription = substr "Kunde $hostgroupName $host - Host $ticketState",0,100;
    }
    my $message          = $incidentDetail;
    my $incidentPriority = "Medium";

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
Notification Type: $notificationType

Kunde:    $hostgroupName
Kundennr: $hostgroupAlias
Host:     $host
";
    if ($serviceTicket) {
        $worklogDetail .= "Service:  $service";
    }
    $worklogDetail .= "
System:   $hostAlias
Address:  $hostAddress
State:    $ticketState

Info->
$ticketOutput

$ticketLongOutput

Date:     $submitDate
Duration: $duration
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

Nagios - Perl module implementing the monitoring driver "Nagios" for MoTMa

=head1 SYNOPSIS

  use Nagios;

=head1 DESCRIPTION

This is the monitoring driver for nagios.

=head2 EXPORT

None by default.



=head1 SEE ALSO

=head1 AUTHOR

Andreas Wenger, E<lt>andreas.wenger@realstuff.chE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by Andreas Wenger

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
