#!/usr/bin/perl
# ------------------------------------------------------------------------------
# Filename:     RemedyForce.pm
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
package RemedyForce;

use strict;
use warnings;
use DBI;
use Data::Dumper;
use MoTMa::Application;
use POSIX qw/strftime/;
use SOAP::Lite;
# To allow trace uncomment the following line.
# use SOAP::Lite +trace => 'all';
use Cache::File;
use Log::Log4perl qw(:easy);
use Alerting;
use JSON;
use HTTP::Request;
use LWP::UserAgent;
use Monitoring;

our $VERSION = $MoTMa::Application::VERSION;

our ($header, $createProxy, $createUri, $createTpl, $createAction, $getProxy, $getUri, $getAction, $instanceName,
    $loginAction, $loginProxy, $loginUri, %ticketTemplate, $updateProxy, $updateUri, $updateAction, $monitoringStatusPage,
    $bearerToken, $remedyforceREST, $salesforceREST, $salesforceBusinessService, $salesforceServiceOffering, $user,
    $password, $ticketClosedState);

my $logger = get_logger();
my $alerter = new Alerting();
my $monitoring = new Monitoring();
my $cache = Cache::File->new( cache_root => '/tmp/cache_demo' );

# Preloaded methods go here.
sub new {
    my $class = shift;
    my $self = {};

    $loginProxy = $MoTMa::Application::loginProxy;
    $loginUri = $MoTMa::Application::loginUri;
    $loginAction = $MoTMa::Application::loginAction;
    $user = $MoTMa::Application::ticketUser;
    $password = $MoTMa::Application::ticketPassword;

    $remedyforceREST = $MoTMa::Application::remedyforceREST;
    $salesforceREST = $MoTMa::Application::salesforceREST;
    $salesforceBusinessService = $MoTMa::Application::salesforceBusinessService;
    $salesforceServiceOffering = $MoTMa::Application::salesforceServiceOffering;

    # $logger->info("Username: ".$user." Password: ".$password."!");

    # $logger->info("loginProxy: ".$loginProxy." loginUri: ".$loginUri." loginAction: ".$loginAction);
    
    # $createProxy = $MoTMa::Application::createProxy;
    # $createUri = $MoTMa::Application::createUri;
    # $createTpl = $MoTMa::Application::createTpl;
    # $createAction = $MoTMa::Application::createAction;
    
    # $getProxy = $MoTMa::Application::getProxy;
    # $getUri = $MoTMa::Application::getUri;
    # $getAction = $MoTMa::Application::getAction;

    # $updateProxy = $MoTMa::Application::updateProxy;
    # $updateUri = $MoTMa::Application::updateUri;
    # $updateAction = $MoTMa::Application::updateAction;
    
    # $instanceName = $MoTMa::Application::instanceName;
    # %ticketTemplate = split(/[=;]/, $MoTMa::Application::ticketTemplate);
    $ticketClosedState = $MoTMa::Application::ticketClosedState;
    $monitoringStatusPage = $MoTMa::Application::monitoringStatusPage;

    if (login()) {
        $logger->trace("Login to RemedyForce successfull!");
    }
    else {
        $logger->error("Login not possible!");
    }

    # $logger->info("RemedyForce Version: ".Dumper(version()));

    
    
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

    my $createdTicket;
    use POSIX qw(strftime);

    my $datestring = strftime "%F %H:%M:%S", localtime;

    # Get the Ticket details
    my ($incidentPriority, $incidentDescription, $incidentDetail, $customerName, $productName,$companyName,
        $worklogDescription, $worklogDetail) = $monitoring->getIncidentDetails($ticket, $serviceTicket);

    # Replace newlines by \n in String. This is because JSON can not handle newlines.
    $incidentDetail =~ s/\n/\\n/g;
    
    # The Create incident Remedyforce API accepts only Description, OpenDateTime, DueDateTime, and ClientId
    # fields while creating an incident. To populate fields such as template or custom fields for an incident, use 
    # Salesforce platform REST API. For more information about Salesforce platform REST API, see the Salesforce
    # Help on: https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/dome_sobject_create.htm
    my $content = '{
        "Description": "'.$incidentDescription.'",
        "OpenDateTime": "'.$datestring.'"
    }';

    # Sapmple JSON to create Incident on Remedyforce.
    # {
    #     "Description": "IT Queue from REST API",
    #     "OpenDateTime": "2018-09-11 04:23:00",
    #     "DueDateTime": "2018-09-12 04:23:00",
    #     "ClientId":  "0050Y000003hI9HQAU",
    #     "IncidentSource": "Source"
    # }
    
    $logger->info("Try to create Incident with content: ".$content);

    my $response = _API_POST($remedyforceREST."Incident", $content);

    $logger->info(Dumper($createdTicket));

    if ($response != 0) {
        # We have to update the Incident with detailed Infos.

        # Get the Host ID
        my $hostId = $cache->get( $ticket->{'host'}.'_ID' );
        if (not defined $hostId) {
            $logger->info("No HostID available. Try to get new one for: ".$ticket->{'host'});
            
            $hostId = $self->getSalesForceId($ticket->{'host'}, 'BMCServiceDesk__HostName__c', 'BMCServiceDesk__BMC_BaseElement__c');

            $cache->set( $ticket->{'host'}.'_ID', $hostId );
        }

        # get BusinessService ID
        my $businessServiceId = $cache->get($salesforceBusinessService.'_FKBusinessService');
        if (not defined $businessServiceId) {
            $logger->info("No FKBusinessService available. Try to get new one for: ".$salesforceBusinessService);

            $businessServiceId = $self->getSalesForceId( $salesforceBusinessService, 'BMCServiceDesk__Name__c', 'BMCServiceDesk__BMC_BaseElement__c');
            $cache->set( $salesforceBusinessService.'_FKBusinessService', $businessServiceId);
        }

        # get ServiceOffering ID
        my $serviceOfferingId = $cache->get($salesforceServiceOffering.'_FKServiceOffering');
        if (not defined $serviceOfferingId) {
            $logger->info("No FKServiceOffering available. Try to get new one for: ".$salesforceServiceOffering);

            $serviceOfferingId = $self->getSalesForceId($salesforceServiceOffering, 'BMCServiceDesk_Name__c', 'BMCServiceDesk__BMC_BaseElement__c');

            $cache->set( $salesforceServiceOffering.'_FKServiceOffering', $serviceOfferingId);
        }

        # get Impact ID
        my $impactId = $cache->get($incidentPriority.'_FKImpact');
        if (not defined $impactId) {
            $logger->info("No FKImpact available. Try to get new on for: ".$incidentPriority);

            $impactId = $self->getSalesForceId($incidentPriority, 'Name', 'BMCServiceDesk__Impact__c');

            $cache->set( $incidentPriority.'_FKImpact', $impactId);
        }

        # get Urgency ID
        my $urgencyId = $cache->get('MEDIUM_FKUrgency');
        if (not defined $urgencyId) {
            $logger->info("No FKUrgency available. Try to get new on for: ".$incidentPriority);

            $urgencyId = $self->getSalesForceId($incidentPriority, 'Name', 'BMCServiceDesk__Urgency__c');

            $cache->set( $incidentPriority.'_FKUrgency', $urgencyId );
        }

        # Update the ticket
        # In the moment we do net set the shortDescription. 
        # "BMCServiceDesk__shortDescription__c": "'.$incidentDetail.'",
        # "Tier__c":"Important",
        my $content = '{
            "BMCServiceDesk__incidentDescription__c": "'.$incidentDetail.'",
            "BMCServiceDesk__FKBusinessService__c": "'.$businessServiceId.'",
            "BMCServiceDesk__FKServiceOffering__c": "'.$serviceOfferingId.'",
            "BMCServiceDesk__FKBMC_BaseElement__c": "'.$hostId.'",
            "BMCServiceDesk__FKImpact__c": "'.$impactId.'",
            "BMCServiceDesk__FKUrgency__c":"'.$urgencyId.'"
        }';

        $logger->info("Try to update Ticket: ".$content);
        
        my $url = $salesforceREST.'sobjects/BMCServiceDesk__Incident__c/';

        if (_API_PATCH($url.$response->{'Result'}->{'Id'}, $content)) {
            $logger->info("Ticket updated :-)");
        }
        else {
            $logger->info("Ticket not updated :-(");
        }

        # Add note to the ticket
        my $content = '{
            "ParentId": "'.$response->{'Result'}->{'Id'}.'",
            "Title": "'.$incidentDescription.'",
            "Body": "'.$incidentDetail.'"
        }';

        $logger->info("Try to add Note: ".$content);

        $url = $salesforceREST.'sobjects/Note/';

        if (_API_POST($url, $content)) {
            $logger->info("Note added to Incident  <".$response->{'Result'}->{'Id'}."> :-)");
        }
        else {
            $logger->info("Note not added to Incident  <".$response->{'Result'}->{'Id'}."> :-(");
        }
 
        return $response->{'Result'}->{'Id'};
    }
    else {
        return 0;
    }
}

sub update {
    my $self            = shift;
    my $ticket          = shift;
    my $idTicket        = shift;
    my $autoClose       = shift;
    my $serviceTicket   = shift;
    my $ticketNumber    = shift;

    my $return = 0;

    # Get the Ticket details
    my ($incidentPriority, $incidentDescription, $incidentDetail, $customerName, $productName,$companyName,
        $worklogDescription, $worklogDetail) = $monitoring->getIncidentDetails($ticket, $serviceTicket);

    # Replace newlines by \n in String. This is because JSON can not handle newlines.
    $incidentDetail =~ s/\n/\\n/g;

    # update incident with status on autoclose
    if ($autoClose) {
        # get resolvedStatus ID
        my $ticketClosedStateId = $cache->get( $ticketClosedState.'_FKStatus' );
        if (not defined $ticketClosedStateId) {
            $logger->debug("No FKStatus available. Try to get new one for: ".$ticketClosedState);

            $ticketClosedStateId = $self->getSalesForceId($ticketClosedState, 'Name', 'BMCServiceDesk__Status__c');

            $cache->set( $ticketClosedState.'_FKStatus', $ticketClosedStateId);
        }

        # Update the ticket
        my $content = '{
            "BMCServiceDesk__FKStatus__c": "'.$ticketClosedStateId.'",
            "BMCServiceDesk__incidentResolution__c": "Autoclose by MoTMa (GroundWork)"
        }';

        $logger->debug("Try to update Ticket: ".$content);
        
        my $url = $salesforceREST.'sobjects/BMCServiceDesk__Incident__c/';

        if (_API_PATCH($url.$ticketNumber, $content)) {
            $logger->debug("Ticket updated :-)");
            $return = 1;
        }
        else {
            $logger->error("Ticket not updated :-(");
            $return = 0;
        }
    }


    # Add note to the ticket
    my $content = '{
        "ParentId": "'.$ticketNumber.'",
        "Title": "'.$incidentDescription.'",
        "Body": "'.$incidentDetail.'"
    }';

    # Just adding notes to the ticket
    $logger->debug("Try to add Note: ".$content);

    my $url = $salesforceREST.'sobjects/Note/';

    if (_API_POST($url, $content)) {
        $logger->trace("Note added to Incident  <".$idTicket."> :-)");
        $return = 1;
    }
    else {
        $logger->error("Note not added to Incident  <".$idTicket."> :-(");
        $return = 0;
    }

    return $return;
}

sub get {
    my $self            = shift;
    my $idTicket        = shift;
    my $idITSMTicket    = shift;
    
    # return connectToRemedy($getProxy, $getUri, $getAction, $self->soapTicketDetailGet($idTicket, $idITSMTicket));
}

sub getTicket {
    my $self            = shift;
    my $idTicket        = shift;
    my $idITSMTicket    = shift || '';
    
    my $itsmTicket;
    if ($idITSMTicket eq '') {
        $idITSMTicket = $self->getTicketNumber($idTicket);
    }

    my $url = $salesforceREST.'sobjects/BMCServiceDesk__Incident__c/'.$idITSMTicket;

    my $ticketDetails = _API_GET( $url );

    if ($ticketDetails ne 0) {
        # Build itsmTicket as used in runLin.pl
        $itsmTicket->{'incidentnumber'} = $idITSMTicket;
        $itsmTicket->{'status'} = $ticketDetails->{'BMCServiceDesk__Status_ID__c'};
    }

    return $itsmTicket;
}

sub getTicketNumber {
    my $self            = shift;
    my $idTicket        = shift;
    
    my $idITSMTicket = '';

    # We cannot use HelpDesk here. So we do dbi on our own.
    my $sth;
    my $dbh = DBI->connect( $MoTMa::Application::dbDsn, $MoTMa::Application::dbUser, $MoTMa::Application::dbPassword, {
        RaiseError => 1 }) or die $DBI::errstr;
    my $query = "SELECT ticketnumber FROM tickets WHERE idtickets = ?;";

    eval {
        $sth = $dbh->prepare($query);
        $sth->execute($idTicket);
        $logger->trace("Query: ".$query." with: ".$idTicket);
    };
    if ($@) {
        $sth->finish();
        $logger->error("DB problem: ".Dumper($@));
    }
    else {
        ($idITSMTicket) = $sth->fetchrow_array();
        $sth->finish();
    }

    return $idITSMTicket;
}

#
# 
sub login {
    my $self = shift;

    my $bearerToken = $cache->get( 'BearerToken' );
 
    if (not defined $bearerToken) {
        $logger->info("No BearerToken available. Try to get new one.");

        my $soap = SOAP::Lite->new( proxy => $loginProxy);
        my $som;

        # Default Namespace for Salesforce (RemedyForce)
        $soap->default_ns($loginUri);

        $logger->trace("Username: ".$user." Password: ".$password."!");
        $logger->trace("LoginProxy:".$loginProxy." loginUri: ".$loginUri." loginAction: ".$loginAction);

        eval {
            # Execute the login action with login data
            $som = $soap->call($loginAction,
                SOAP::Data->name('username')->value($user),
                SOAP::Data->name('password')->value($password)
            );
        };
        if ($@) {
            # Sending doesn't work
            
            # Cause
            # - Connection not posible
            $logger->error("RemedyForce - Could not connect: ".$@);
            
            $alerter->save("RemedyForce - Could not connect",
"#########################################################
## GroundWork 2 RemedyForce - Could not connect!!       #
#########################################################

Please check RemedyForce and GroundWork
There was an error while connecting to RemedyForce ".$@);               

            return 0;
        }

        # Check for SOAP fault
        if ( $som->fault ) {
            my $faultcode   = $som->faultcode;
            my $faultstring = $som->faultstring;
            my $faultdetail = $som->faultdetail;
            
            # API ended with error - Look at $faultstring
            $logger->error("RemedyForce - SOAP ERROR - Could not call login!
SOAP FAULTCODE: $faultcode
SOAP FAULTSTRING: $faultstring
SOAP FAULTDETAIL: ".Dumper($faultdetail));

        $alerter->save("not updated - Please check the Notifications on GroundWork!",
"##############################################################
# SOAP ERROR - Update Ticket on RemedyForce - doesn't work:!! #
###############################################################

SOAP FAULTCODE: $faultcode
SOAP FAULTSTRING: $faultstring
SOAP FAULTDETAIL: ".Dumper($faultdetail)."
");
            
            # something whent wrong - could not connect to ARS. So the calling function has to care about.
            return 0;
        }   

        # Get the bearer token from the response
        $bearerToken = $som->result->{'sessionId'};
        my $sessionSecondsValid = $som->result->{'userInfo'}->{'sessionSecondsValid'};
        $cache->set( 'BearerToken', $bearerToken, ($sessionSecondsValid-60).' s' );
        $logger->debug("Got Bearer token: ".$bearerToken.". Saved into Cache for ".($sessionSecondsValid-60)." Seconds!")
    }
    else {
        $logger->info("BearerToken already available!");
    }

    # Make Bearer Token available for application
    $RemedyForce::bearerToken = $bearerToken;

    return 1;
}

sub version {
    my $self = shift;

    my $url = $remedyforceREST.'ServiceUtil/Version';

    _API_GET($url);
   
}

sub searchParametrized {
    my ( $self, $query, $sobjectType ) = @_;

    my $url = $salesforceREST."parameterizedSearch?q=".$query."&sobject=".$sobjectType;

    return _API_GET( $url );
}

sub getsobjects {
    my ( $self, $salesforceId, $sobjectType ) = @_;

    my $url = $salesforceREST."sobjects/".$sobjectType."/".$salesforceId;

    $logger->trace("URL: ".$url);

    return _API_GET( $url );
}

# This sub can be used for hosts, BusinessService and ServiceOffering
sub getSalesForceElementDetail {
    my ( $self, $salesforceId, $sobjectType) = @_;

    return $self->getsobjects($salesforceId, $sobjectType);
}

# Get a BaseElement from salesforce
sub getSalesForceId {
    my $self            = shift;
    my $query           = shift;
    my $name            = shift;
    my $sobjectType     = shift; 

    # get the BaseElementId
    my $response = $self->searchParametrized($query, $sobjectType);

    $logger->trace("SalesForce Element: ".$query." sobject type: ".$sobjectType.". Response: ".Dumper($response));

    # Sometimes the query is has not an exact match. So we try to find the corresponding element
    my $searchRecords = $response->{'searchRecords'};
    my $searchRecordsCount = scalar @$searchRecords;
    if ($searchRecordsCount == 0) {
        $logger->error("No BaseElement: ".$query." found!");
        return undef;
    }
    elsif ($searchRecordsCount >= 1) {
        if ($searchRecordsCount > 1) {
            foreach (@$searchRecords) {
                my $idTemp = $_->{'Id'};
                $logger->trace("ID IS: ".$idTemp." Dumper: ".Dumper($_));
                my $salesForceElementDetail = $self->getSalesForceElementDetail($idTemp, $sobjectType);

                $logger->trace("salesForceElementDetail: ".Dumper($salesForceElementDetail));

                if ($query eq $salesForceElementDetail->{$name}) {
                    return $idTemp;
                }
            }

            # If the query didn't match with search results
            $logger->error("No salesForceElementDetail: ".$query." found!");
            return undef;
        }
        else {
            return $response->{'searchRecords'}[0]->{'Id'};
        }
    }
}

sub _API_GET {
    my ( $url ) = @_;

    # Set the headers
    my $header = [
        'Authorization' => 'Bearer '.$RemedyForce::bearerToken,
        'Content-Type' => 'application/json',
        'Content-Length' => '0',
        'Accept' => '*/*'];

    $logger->trace("Url: ".$url);

    # Prepare the request
    my $r = HTTP::Request->new('GET', $url, $header);
    
    # create the user agent
    my $ua = LWP::UserAgent->new();

    # Allow redirects
    # push @{ $ua->requests_redirectable }, 'POST';
    my $res = $ua->request($r);

    if ($res->is_success) {
        $logger->trace("GET Request (".$url.") results in: ".$res->decoded_content);
        return decode_json($res->decoded_content);
    }
    else {
        $logger->error("GET Request not successfull to ".$url.". Response Status: ".$res->status_line);
        return 0;
    }
}

sub _API_POST {
    my ( $url, $content ) = @_;

    # Set headers for request
    my $header = [
        'Authorization' => 'Bearer '.$RemedyForce::bearerToken,
        'Content-Type' => 'application/json',
        'Accept' => '*/*'];

    $logger->trace("Url: ".$url);

    # Prepare the request
    my $r = HTTP::Request->new('POST', $url, $header);

    # add content to the request
    $r->content($content);

    # Create the user agent
    my $ua = LWP::UserAgent->new();

    # Execute the request
    my $res = $ua->request($r);

    if ($res->is_success) {
        $logger->trace("POST Request (".$url.") results in: ".$res->decoded_content);
        return decode_json($res->decoded_content);
    }
    else {
        $logger->error("POST Request not successfull to ".$url.". Response Status: ".$res->status_line);
        return 0;
    }
}

sub _API_PATCH {
    my ( $url, $content ) = @_;

    # Set headers for request
    my $header = [
        'Authorization' => 'Bearer '.$RemedyForce::bearerToken,
        'Content-Type' => 'application/json',
        'Accept' => '*/*'];

    # Prepare the request
    my $r = HTTP::Request->new('PATCH', $url, $header);

    # add content to the request
    $r->content($content);

    # Create the user agent
    my $ua = LWP::UserAgent->new();

    # Execute the request
    my $res = $ua->request($r);

    if ($res->is_success) {
        # PATCH requests will give empty responses.
        $logger->trace("PATCH Request (".$url.") results in: ".$res->decoded_content);
        # print Dumper(decode_json($res->decoded_content));
        # return decode_json($res->decoded_content);
        return 1;
    }
    else {
        $logger->error("PATCH Request not successfull to ".$url.". Response Status: ".$res->status_line);
        return 0;
    }
}

1;
__END__

=head1 NAME

Remedy - Perl module implementing a sample Remedy ticketing driver.

=head1 SYNOPSIS

  use Remedy;

=head1 DESCRIPTION

Remedy implements an ticketing driver to access an Remedy ticketing systems by webservices.

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
