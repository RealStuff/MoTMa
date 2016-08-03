#!/usr/bin/perl
# ------------------------------------------------------------------------------
# Filename:     Application.pm
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
# Copyright (c) 2016 RealStuff Informatik AG (www.realstuff.ch).
#
package MoTMa::Application;

use strict;
use warnings;
use Config::IniFiles;
use Data::Dumper;
use Cwd;
use Cwd 'abs_path';
use File::Basename;
use DBI;
use Alerting;

# basePath - where is our application located
our $basePath = dirname(abs_path($0));
if ($basePath =~ /bin$/ ) {
    $basePath =~ s/bin$// ;
}
else {
    $basePath =~ s/t$// ;
}

our $cfg =  new Config::IniFiles ( -file => $basePath."etc/motma.ini" );

# createTemplate - This is the perl based template to the ticketing Interface for create operations
our $createTemplate =  $basePath.$cfg->val('BMC', 'createTpl', '-');
# removing white spaces
$createTemplate =~s/\s+$//;
my $dbDriver = $cfg->val('database', 'driver', "SQLite");
if ($dbDriver eq "SQLite") {
    our $dbDsn = "DBI:SQLite:dbname=".
        $basePath.$cfg->val('database', 'database', "data/data.db");
}
elsif ($dbDriver eq "Pg") {
    our $dbDsn = "DBI:Pg:dbname=".$cfg->val('database', 'database', "helpdesk").
        ";host=".$cfg->val('host', 'host', "localhost").";port=5432";
}
our $dbUser = $cfg->val('database', 'user', "");
our $dbPassword = $cfg->val('database', 'password', "");
our $debug = $cfg->val('global', 'debug', '0');
our $correlation = $cfg->val('global', 'correlation', 'host;service');

our $monitoringDriver = $cfg->val('global', 'monitoringdriver', 'NAGIOS');
our $monitoringEnv = $cfg->val($monitoringDriver, 'env');
our $monitoringStatusPage = $cfg->val($monitoringDriver, 'statusPage');

our $ticketDriver = $cfg->val('global', 'ticketdriver', 'REMEDY');
our $ticketUser = $cfg->val($ticketDriver, 'user', '');
our $ticketPassword = $cfg->val($ticketDriver, 'password', '');
our $ticketClosedState = $cfg->val($ticketDriver, 'closedState', 'Resolved');

our $createProxy = $cfg->val($ticketDriver, 'createProxy', '');
our $createUri = $cfg->val($ticketDriver, 'createUri', '');
our $createAction = $cfg->val($ticketDriver, 'createAction', '');

our $getProxy = $cfg->val($ticketDriver, 'getProxy', '');
our $getUri = $cfg->val($ticketDriver, 'getUri', '');
our $getAction = $cfg->val($ticketDriver, 'getAction', '');

our $updateProxy = $cfg->val($ticketDriver, 'updateProxy', '');
our $updateUri = $cfg->val($ticketDriver, 'updateUri', '');
our $updateAction = $cfg->val($ticketDriver, 'updateAction', '');

our $instanceName = $cfg->val($ticketDriver, 'instanceName', '');
our $ticketTemplate = $cfg->val($ticketDriver, 'ticketTemplate', '');
our $updateTicket = $cfg->val($ticketDriver, 'updateTicket', '0');
our $autoClose = $cfg->val($ticketDriver, 'autoClose', '0');
    
our $closedHelpdeskState = "CLOSED";

our $alertingDriver = $cfg->val('global', 'alertingdriver', 'FILE');
our $alertingFrom = $cfg->val($alertingDriver, 'from', 'root@localhost');
our $alertingTo = $cfg->val($alertingDriver, 'to', 'root@localhost');
our $alertingSmtp = $cfg->val($alertingDriver, 'smtp', '');
our $alertingSubject = $cfg->val($alertingDriver, 'subject', '');
our $alertingExpiration = $cfg->val('global', 'expired', '300s');
our ($alertingExpirationUnit) = $alertingExpiration =~ /(.)$/;
our ($alertingExpirationTime) = $alertingExpiration =~ /^(\d+)/;

our $updateWorking = $cfg->val('global', 'updateworking', 0);

our $VERSION = '0.1';