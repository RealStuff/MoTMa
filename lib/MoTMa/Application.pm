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
# Copyright (c) 2014 RealStuff Informatik AG (www.realstuff.ch).
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

# basePath - where is our application located
our $basePath = dirname(abs_path($0));
$basePath =~ s/bin$// ;
# print "BasePath: ".$basePath."\n";
our $cfg =  new Config::IniFiles ( -file => $basePath."conf/motma.ini" );

# createTemplate - This is the perl based template to the ticketing Interface for create operations
our $createTemplate =  $basePath.$cfg->val('BMC', 'createTpl', '-');
# removing white spaces
$createTemplate =~s/\s+$//;
our $dbDsn = "DBI:".$cfg->val('database', 'driver', "SQLite").":dbname=".$basePath.$cfg->val('database', 'database', "data/data.db");
our $dbUser = $cfg->val('database', 'user', "");
our $dbPassword = $cfg->val('database', 'password', "");
our $VERSION = '0.1';