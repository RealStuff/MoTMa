package Remedy;

use strict;
use warnings;
use DBI;
use Data::Dumper;
use MoTMa::Application;
use POSIX qw/strftime/;
use SOAP::Lite;
# To allow trace uncomment the following line.
# use SOAP::Lite +trace => 'all';
use Log::Log4perl qw(:easy);
use Alerting;

our $VERSION = $MoTMa::Application::VERSION;

our ($header, $createProxy, $createUri, $createTpl, $createAction, $getProxy, $getUri, $getAction, $instanceName,
    %ticketTemplate, $updateProxy, $updateUri, $updateAction, $monitoringStatusPage);

my $logger = get_logger();
my $alerter = new Alerting();

# Preloaded methods go here.
sub new {
    my $class = shift;
    my $self = {};
    
    $header = SOAP::Header->name(
        'AuthenticationInfo' => \SOAP::Header->value(
            SOAP::Header->name( 'userName'       => $MoTMa::Application::user )->type(''),
            SOAP::Header->name( 'password'       => $MoTMa::Application::password )->type(''),
            SOAP::Header->name( 'authentication' => '' )->type(''),
            SOAP::Header->name( 'locale'         => $MoTMa::Application::locale )->type(''),
            SOAP::Header->name( 'timeZone'       => '' )->type(''),
        )
    );
    
    $createProxy = $MoTMa::Application::createProxy;
    $createUri = $MoTMa::Application::createUri;
    $createTpl = $MoTMa::Application::createTpl;
    $createAction = $MoTMa::Application::createAction;
    
    $getProxy = $MoTMa::Application::getProxy;
    $getUri = $MoTMa::Application::getUri;
    $getAction = $MoTMa::Application::getAction;

    $updateProxy = $MoTMa::Application::updateProxy;
    $updateUri = $MoTMa::Application::updateUri;
    $updateAction = $MoTMa::Application::updateAction;
    
    $instanceName = $MoTMa::Application::instanceName;
    %ticketTemplate = split(/[=;]/, $MoTMa::Application::ticketTemplate);
    $monitoringStatusPage = $MoTMa::Application::monitoringStatusPage;
    
    bless $self, $class;
    return $self;
}

sub DESTROY {
    
}

sub create {
    my $self            = shift;
    my $ticket          = shift;
    my $idTicket        = shift;
    my $serviceTicket   = shift;
    
    return connectToRemedy($createProxy, $createUri, $createAction, $self->soapTicketDetailCreate($ticket, $idTicket,
            $serviceTicket));
}

sub update {
    my $self            = shift;
    my $ticket          = shift;
    my $idTicket        = shift;
    my $autoClose       = shift;
    my $serviceTicket   = shift;
    
    my $body = $self->soapTicketDetailUpdate($ticket, $idTicket, $autoClose, $serviceTicket);

    return connectToRemedy($updateProxy, $updateUri, $updateAction, $body);
}

sub get {
    my $self            = shift;
    my $idTicket        = shift;
    my $idITSMTicket    = shift;
    
    return connectToRemedy($getProxy, $getUri, $getAction, $self->soapTicketDetailGet($idTicket, $idITSMTicket));
}

sub getTicket {
    my $self            = shift;
    my $idTicket        = shift;
    my $idITSMTicket    = shift || '';
    
    my $tickets = $self->get($idTicket, $idITSMTicket);



    if ($tickets == 0) {
        return undef;
    }
    else {
        # get the ticket
        # return $tickets->valueof('//incidentlist');
        return $tickets->valueof('//item');
    }
}

sub getTicketNumber {
    my $self            = shift;
    my $idTicket        = shift;
    
    my $ticketNumber = '';
    
    my $tickets = $self->get($idTicket, '');
    my $saved = 0;
    for my $t ($tickets->valueof('//item')) {
        $ticketNumber = $t->{incidentnumber};
        $logger->trace("ITSM-Ticket: ".$ticketNumber." by idTicket: $idTicket");
        $saved = 1;
    }
        
    return $ticketNumber;
}

sub getHelpdeskDetail {
    my $self            = shift;
    my $ticketData      = shift;
    my $idTicket        = shift;
    my $serviceTicket   = shift;
    
    my $incidentPriority = "Medium";
    my $incidentDescription;
    my $incidentDetail;
    my $customerName;
    my $productName;
    my $companyName;
    my $worklogDescription;
    my $worklogDetail;
    my $hostTeamContact = "BT1";
    my $hostgroupName;
    
    my $remedyTemplate;

    # Check if System is Produktion
    if ( $ticketData->{NAGIOS_HOSTALIAS} =~ "m/^Produ|^produ/" ) {
        $incidentPriority = "High";
    }
    
    # Get The Team Information
    $hostTeamContact = $ticketData->{'NAGIOS__HOSTTEAMCONTACT'} if exists $ticketData->{'NAGIOS__HOSTTEAMCONTACT'};
    
    # Set the template for the found Team
    if ($hostTeamContact eq 'OTK') {
        $remedyTemplate = $ticketTemplate{'OTK'};
        $logger->debug("Team: OTK");
    }
    elsif ($hostTeamContact eq 'BT1') {
        $remedyTemplate = $ticketTemplate{'BT1'};
        $logger->debug("Team: BT1");
    }
    elsif ($hostTeamContact eq 'BT2') {
        $remedyTemplate = $ticketTemplate{'BT2'};
        $logger->debug("Team: BT2");
    }
    else {
        $remedyTemplate = $ticketTemplate{'default'};
        $logger->debug("Team: !No Contact information found!");
    }
    
    $hostgroupName = join('',grep(!/^z{1,2}?_/, split(",", $ticketData->{'NAGIOS_HOSTGROUPNAMES'})));
    
    $logger->trace("HostGroupName: $hostgroupName");
    
    # incident
    if ($serviceTicket) {
        $incidentDescription = substr "Kunde $hostgroupName ".$ticketData->{'NAGIOS_SERVICEDESC'}."/".
            $ticketData->{'NAGIOS_HOSTNAME'}." - Service ".$ticketData->{'NAGIOS_SERVICESTATE'},0,100;
    }
    else {
        $incidentDescription = substr "Kunde $hostgroupName ".$ticketData->{'NAGIOS_HOSTNAME'}." - Host ".
            $ticketData->{'NAGIOS_HOSTSTATE'},0,100;
    }

    # The default Productname
    $productName = "SAP Services";
    # The default Customer
    $companyName = "Swisscom IT Services Enterprise Solutions AG";

    # worklog
    $worklogDescription = $incidentDescription;
    $worklogDetail      = "***** GroundWork ".$ticketData->{'NAGIOS_LONGDATETIME'}." ****
Notification Type: ".$ticketData->{'NAGIOS_NOTIFICATIONTYPE'}."

Kunde:    $hostgroupName
Kundennr: ".$ticketData->{'NAGIOS_HOSTGROUPALIAS'}."
Host:     ".$ticketData->{'NAGIOS_HOSTNAME'}."
";
    # if ($serviceTicket) {
    $worklogDetail .= "Service:  ".$ticketData->{'NAGIOS_SERVICEDESC'} if $serviceTicket;
    # }
    $worklogDetail .= "
System:   ".$ticketData->{'NAGIOS_HOSTALIAS'}."
Address:  ".$ticketData->{'NAGIOS_HOSTADDRESS'}."
State:    ";
    if ($serviceTicket) {
        $worklogDetail .= $ticketData->{'NAGIOS_SERVICESTATE'}."

Info->
".$ticketData->{'NAGIOS_SERVICEOUTPUT'}."

".$ticketData->{'NAGIOS_LONGSERVICEOUTPUT'};
    }
    else {
        $worklogDetail .= $ticketData->{'NAGIOS_HOSTSTATE'}."

Info->
".$ticketData->{'NAGIOS_HOSTOUTPUT'}."

".$ticketData->{'NAGIOS_LONGHOSTOUTPUT'};;
    }
    
    $worklogDetail .= "

Date:     ".$ticketData->{'NAGIOS_SHORTDATETIME'}."
Duration: ";
    if ($serviceTicket) {
        $worklogDetail .= $ticketData->{'NAGIOS_SERVICEDURATION'};
    }
    else {
        $worklogDetail .= $ticketData->{'NAGIOS_HOSTDURATION'};
    }
    $worklogDetail .= "
Link:     ".$monitoringStatusPage.$ticketData->{'NAGIOS_HOSTNAME'}."&amp;service=".$ticketData->{'NAGIOS_SERVICEDESC'};

    $incidentDetail = $worklogDetail;

    return ($remedyTemplate, $incidentPriority, $incidentDescription, $incidentDetail, $customerName, $productName,
        $companyName, $worklogDescription, $worklogDetail);
}

sub soapTicketDetailCreate {
    my $self            = shift;
    my $ticketData      = shift;
    my $idTicket        = shift;
    my $serviceTicket   = shift;

    my ($remedyTemplate, $incidentPriority, $incidentDescription, $incidentDetail, $customerName, $productName,
        $companyName, $worklogDescription, $worklogDetail) = $self->getHelpdeskDetail($ticketData, $idTicket, $serviceTicket);
    
    return SOAP::Data->value(
    # return SOAP::Data->name(
        # 'SWI_WS_PartnerIncidentCreate_02' => \SOAP::Data->value(
            SOAP::Data->name('partnerincidentnumber')->value($instanceName.$idTicket)->type('xsd:string'),
            SOAP::Data->name('templatenumber')->value($remedyTemplate)->type('xsd:string'),
            SOAP::Data->name(
                'incident' => \SOAP::Data->value(
                    SOAP::Data->name('priority')->value($incidentPriority)->type('xsd:string'),
                    SOAP::Data->name('impact')->value("4-Minor/Localized")->type('xsd:string'),
                    SOAP::Data->name('urgency')->value("3-Medium")->type('xsd:string'),
                    SOAP::Data->name('description')->value($incidentDescription)->type('xsd:string'),
                    SOAP::Data->name('detail')->value($incidentDetail)->type('xsd:string'),
                    #SOAP::Data->name('submitdate')->value($submitDate)->type('xsd:string'),
                    SOAP::Data->name('submitdate')->value("")->type('xsd:string'),
                    SOAP::Data->name('targetresolutiondate')->value("")->type('xsd:string'),
                    SOAP::Data->name('customer')->value($customerName)->type('xsd:string'),
                    SOAP::Data->name('productname')->value($productName)->type('xsd:string'),
                ),
            ),
            SOAP::Data->name(
                'contact' => \SOAP::Data->value( SOAP::Data->name('company')->value($companyName)->type('xsd:string') )
            ),
            SOAP::Data->name(
                'worklog' => \SOAP::Data->value(
                    SOAP::Data->name('description')->value($worklogDescription)->type('xsd:string'),
                    SOAP::Data->name('detail')->value($worklogDetail)->type('xsd:string'),
                    #SOAP::Data->name('submitdate')->value($submitDate)->type('xsd:string'),
                    SOAP::Data->name('submitdate')->value("")->type('xsd:string'),
                    SOAP::Data->name('worklogid')->value("")->type('xsd:string')
                )
            )
        # )
    );
}

sub soapTicketDetailUpdate {
    my $self            = shift;
    my $ticketData      = shift;
    my $idTicket        = shift;
    my $autoClose       = shift || 0;
    my $serviceTicket   = shift;

    my $updateType = "Update";
    
    # get incident details
     my ($remedyTemplate, $incidentPriority, $incidentDescription, $incidentDetail, $customerName, $productName,
        $companyName, $worklogDescription, $worklogDetail) = $self->getHelpdeskDetail($ticketData, $idTicket, $serviceTicket);
    
    if ($autoClose) {
        $updateType = "ClosedBySystem";
    }
    
    $logger->trace( "------- Remedy Ticket update to \"$updateType\" -------");

    #  Building SOAP Request to get a Ticket
    # Partner -> HelpdeskDB
    return SOAP::Data->value(
    # return SOAP::Data->name(
        # 'partnerincidentupdate' => \SOAP::Data->value(
            SOAP::Data->name('partnerincidentnumber')->value($instanceName.$idTicket)->type('xsd:string'),
            SOAP::Data->name('incidentnumber')->value('')->type('xsd:string'),
            SOAP::Data->name('type')->value($updateType)->type('xsd:string'),
            SOAP::Data->name(
                'incident' => \SOAP::Data->value(
                SOAP::Data->name('description')->value($incidentDescription)->type('xsd:string'),
                SOAP::Data->name('detail')->value($incidentDetail)->type('xsd:string'),
                ),
            ),
            SOAP::Data->name(
                'worklog' => \SOAP::Data->value(
                SOAP::Data->name('description')->value($worklogDescription)->type('xsd:string'),
                SOAP::Data->name('detail')->value($worklogDetail)->type('xsd:string'),
                SOAP::Data->name('submitdate')->value("")->type('xsd:string'),
                SOAP::Data->name('worklogid')->value("")->type('xsd:string')
                )
            )
        # )
    );
}

sub soapTicketDetailGet {
    my $self        = shift;
    my $idHelpdesk  = shift;
    my $ticketNo    = shift || undef;

#   my $incidentNumber        = SOAP::Data->name('incidentnumber')->value($ticketNo)->type('xs:string');
#   my $partnerIncidentNumber = SOAP::Data->name('partnerincidentnumber')->value($instanceName.$idHelpdesk)->type('xs:string');
#   my $lookupDate            = SOAP::Data->name('lookupdate')->value("0001-01-01T00:00:00")->type('xs:string');

    return SOAP::Data->value (
        SOAP::Data->name('incidentnumber')->value($ticketNo)->type('xs:string'),
        SOAP::Data->name('partnerincidentnumber')->value($instanceName.$idHelpdesk)->type('xs:string'),
        SOAP::Data->name('lookupdate')->value("0001-01-01T00:00:00")->type('xs:string')
    );
}

sub connectToRemedy {
    my $proxy = shift;
    my $uri = shift;
    my $action = shift;
    my $body = shift;
    
    $logger->trace("SOAP Action: $action\nSOAP Uri: $uri\nSOAP Proxy: $proxy\nSOAP Body: ".Dumper($body));

    my $result;

    # create the soap lite object to use
    #  create it with the target proxy and uri values from above
    my $soap = new SOAP::Lite
        proxy => $proxy,
        uri   => $uri;

    # Create the ticket on the SOAP webservice
    eval {
        no strict "refs";
        # $result = $soap->$action( $header, $body );
        $result = $soap->$action( $body );
    };
    if ($@) {
        # Sending doesn't work
        
        # Cause
        # - Connection not posible
        $logger->error("ARS Remedy - Could not connect to ITSM/Remedy: ".$@);
        
        $alerter->save("ARS Remedy - Could not connect to ITSM/Remedy",
"#########################################################
## GroundWork 2 ITSM/Remedy - Could not connect!!       #
#########################################################

Please check ITSM and GroundWork
There was an error while connecting to ITSM/Remedy ".$@);               

        return 0;
    }

    # Check for SOAP fault
    if ( $result->fault ) {
        my $faultcode   = $result->faultcode;
        my $faultstring = $result->faultstring;
        my $faultdetail = $result->faultdetail;
        
        # API ended with error - Look at $faultstring
        $logger->error("ARS Remedy - SOAP ERROR - Could not call $action!
SOAP FAULTCODE: $faultcode
SOAP FAULTSTRING: $faultstring
SOAP FAULTDETAIL: ".Dumper($faultdetail));

        $alerter->save("not updated - Please check the Notifications on GroundWork!",
"########################################################
# SOAP ERROR - Update Ticket on ARS - doesn't work:!!  #
########################################################

SOAP FAULTCODE: $faultcode
SOAP FAULTSTRING: $faultstring
SOAP FAULTDETAIL: ".Dumper($faultdetail)."

Ticket Details:
------
".$soap->serializer->envelope(
                method => $action, 
                $body
            )
        );
        
        # something whent wrong - could not connect to ARS. So the calling function has to care about.
        return 0;
    }
    
    return $result;
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Helpdesk - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Helpdesk;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Helpdesk, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Andreas Wenger, E<lt>andreas.wenger@realstuff.chE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by Andreas Wenger

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.16.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
