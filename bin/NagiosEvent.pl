#!/usr/local/groundwork/perl/bin/perl
# ------------------------------------------------------------------------------
# Filename:     NagiosEvent.pl
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

use DateTime;
use strict;
use warnings;
use Data::Dumper;
use Cwd;
use Getopt::Long qw(:config no_ignore_case);
use MoTMa::Application;
use HelpDesk;
use POSIX qw/strftime/;

my $VERSION = $MoTMa::Application::VERSION;
my $debug = $MoTMa::Application::debug;
my ( $host, $service, $submitdate, $message, $status, $priority, $category, $parameters, $versions, $help, $man );

# Set default (empty) values
$service = "";
$status = "";
$priority = "";
$category = "";

$man = 0;
$help = 0;
$versions = 0;

main();

###############################################################
# Main Function                                               #
###############################################################
sub main {
	options();
    
    
    
    # Log data to file:
    logfile("Host: $host, Service: $service, Category: $category, Parameters: $parameters, Priority: $priority, "
        ."Message: $message, Status: $status, Submitdate: $submitdate") if $debug;
	
	# Prepare Database Connections
    if (!$submitdate) {
        $submitdate = strftime( '%Y-%m-%d %H:%M:%S', localtime );
    }
    
    # Check if submited values in spec
    checkValues();

    my $helpDesk = new HelpDesk();
    
    $helpDesk->insertEvent($host, $service, $category, $parameters, $priority, $message, $status, $submitdate);
}

###############################################################
# Check parameters if their content is valid                  #
###############################################################
sub checkValues() {
    # Check for allowed status
    if (not($status =~/^OK$|^UP$|^CRITICAL$|^DOWN$|^WARNING$|^UNKNOWN$|^PENDING$/)) {
        logfile("!!!!!! Notification not successful - Unknown Status: '$status' !!!!!!") if $debug;
        usage();
    }
    
    # get Nagios Environment vars
    my @envVar = split(/;/, $MoTMa::Application::monitoringEnv);
    # print "Motma:".$MoTMa::Application::monitoringEnv;
    # print Dumper @envVar;
    
    my %monitoringEnv = map { $_ => 1 } @envVar;
    # print "< MonitoringEvn:" . Dumper(%monitoringEnv) . ">";
    foreach (sort keys %ENV) {
        # if ($_ =~ /^NAGIOS_/) {
        #     # logfile($_."\n");
        #     logfile($_);
        #     # $_ =~ s/NAGIOS_//g;
        #     # logfile($_.$monitoringEnv{$_});
        #     # logfile("MonitoringEnv: ".$monitoringEnv{$_}."::".$_);
        #     # logfile("NAGIOS_".$_);
            if (exists $monitoringEnv{$_}) {
                $parameters .= "$_=$ENV{$_};";
                logfile("Saved");
            }
        # }
    }
    # Remove trailing ';'
    $parameters =~ s/;$//;
    
    # Check if submitdate is unixtimestamp
    my $dt;
    if (($submitdate =~ m/\d{10}/) ) {
        $dt = DateTime->from_epoch(epoch => $submitdate)->set_time_zone(DateTime::TimeZone::Local->TimeZone());
        $submitdate = $dt->ymd.' '.$dt->hms;
    }
    # check if submitdate is correct date timestamp 
    elsif (not($submitdate =~ m/^\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2}$/)) {
        logfile("!!!!!! Notification not successful - Wrong submitdate: '$submitdate' !!!!!!") if $debug;
        usage();
    }
}

###############################################################
# Log Message to log File                                     #
###############################################################
sub logfile() {
    my $logMessage = shift;
    
    my $filename = $MoTMa::Application::basePath.'var/log/notifications.log';
    open(my $fh, '>>', $filename) or die "Could not open file '$filename' $!";
    print $fh "$logMessage\n";
    close $fh;
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

NagiosEvent.pl

=head1 SYNOPSIS

NagiosEvent.pl [B<--help>] [B<--man>] [B<--versions>]
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
     Monitoringstatus of the event (UP, DOWN, OK, CRITICAL, UNKNOWN, PENDING, WARNING)

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

=head1 TESTED

Not Tested

=head1 BUGS

None that I know of.

=head1 TODO
  
=head1 UPDATES

 2016-03-30 14:29:17 CEST
   Initial working code.

=cut
