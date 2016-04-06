#!/usr/local/groundwork/perl/bin/perl
# ------------------------------------------------------------------------------
# Filename:     sendEvent.pl
# Author:       Andreas Wenger, RealStuff Informatik AG (http://www.realstuff.ch)
# Since:        0.1
# Abstract:
#
# ------------------------------------------------------------------------------
# Edition history:
#
# 2014/06/19    awe     Initial version
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
use Data::Dumper;
use Cwd;
use Getopt::Long qw(:config no_ignore_case);
use MoTMa::Application;
use HelpDesk;
use POSIX qw/strftime/;

my $VERSION = $MoTMa::Application::VERSION;
my ( $host, $service, $submitdate, $message, $status, $priority, $category, $parameters, $versions, $help, $man );
$service = "";
$man = 0;
$help = 0;
$versions = 0;

main();

###############################################################
# Main Function                                               #
###############################################################
sub main {
	options();
	
	# Prepare Database Connections
    if (!$submitdate) {
        $submitdate = strftime( '%Y-%m-%d %H:%M:%S', localtime );
    }

    my $helpDesk = new HelpDesk();
  
    $helpDesk->insertEvent($host, $service, $category, $parameters, $priority, $message, $status, $submitdate);
}

###############################################################
# Read options from parameters                                #
###############################################################
sub options() {
    #my $help = 0;     # handled localy
    # Process Options
    if (@ARGV > 0) {
        GetOptions('host|H=s'     => \$host,
            'service|s:s'       => \$service,
            'message|m=s'       => \$message,
            'status|S=s'        => \$status,
            'priority|p:s'      => \$priority,
            'category|c:s'      => \$category,
            'parameters|P:s'     => \$parameters,
            'submitdate|d:s'    => \$submitdate,
            'versions'          => \$versions,
            'help|h|?'          => \$help,
            'manual'            => \$man) or usage(2);
    }
    if ($man or $help or $versions) {
        # print "Man: ".$man."\n";
        # print "Help: ".$help."\n";
        # print "Versions: ".$versions."\n";
        usage();
    }
}

###############################################################
# Usage function, used for help                               #
###############################################################
sub usage () {
    my $level = shift;
  
    if (!defined($level)) {
        $level = 2
    }
    # Load Pod::Usage only if needed.
    require "Pod/Usage.pm";
    import Pod::Usage;
    if ($man or $help or $versions) {
        pod2usage(1) if $help;
        pod2usage(VERBOSE => 2) if $man;
        print
            "\nModules, Perl, OS, Program info:\n",
            "  Pod::Usage            $Pod::Usage::VERSION\n",
            "  Getopt::Long          $Getopt::Long::VERSION\n",
            "  strict                $strict::VERSION\n",
            "  Perl version          $]\n",
            "  Perl executable       $^X\n",
            "  OS                    $^O\n",
            "  $0                    $VERSION\n",
            "\n\n" if $versions;
    }
    else {
        pod2usage($level);
    }
    exit 1;
}

__END__

=pod

=head1 Name

sendEvent.pl

=head1 SYNOPSIS

sendEvent.pl [B<--help>] [B<--man>] [B<--versions>]
    B<-H> I<host> [B<-s> I<service>] B<-m> I<message> [B<-p> I<priority>] [B<-c> I<category>] [B<-P> I<parameter(s)>] 
    [B<-d> I<timestamp>] B<-S> I<status>

=head1 DESCRIPTION

This scripts saves events from your monitoring into a database.

=head1 ARGUMENTS

 -H host
     Hostname the event is occuring
 
 -s service
     Servicename (servicedescription) the event is occuring
 
 -m message
     Message of the Event
     
 -p priority
     Priority of the event
     
 -c category
     Category of the event
     
 -P parameters
     Parameters allows to store more information for a specific event
 
 -d timestamp
     Timestamp the event occurs
     
 -S status
     Monitoringstatus of the event

=head1 OPTIONS

 --versions
        print Modules, Perl, OS, Program info
 --help|h|?      
        print Options and Arguments
 --man
        print complete man page

=head1 EXAMPLES


          
=head1 AUTHOR

Andreas Wenger (at) RealStuff Informatik AG

=head1 CREDITS

Credits goes to RealStuff Informatik AG

=head1 LICENSE

LGPL 

=head1 TESTED

Not Tested

=head1 BUGS

None that I know of.

=head1 TODO
  
=head1 UPDATES

 2016-03-30 14:29:17 CEST
   Initial working code.

=cut