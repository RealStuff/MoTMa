#!/usr/local/groundwork/perl/bin/perl -w

# COPYRIGHT:
#  
# This software is Copyright (c) 2007 NETWAYS GmbH, Christian Doebler 
#                                <support@netways.de>
# 
# (Except where explicitly superseded by other copyright notices)
# 
# 
# LICENSE:
# 
# This work is made available to you under the terms of Version 2 of
# the GNU General Public License. A copy of that license should have
# been provided with this software, but in any event can be snarfed
# from http://www.fsf.org.
# 
# This work is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301 or visit their web page on the internet at
# http://www.fsf.org.
# 
# 
# CONTRIBUTION SUBMISSION POLICY:
# 
# (The following paragraph is not intended to limit the rights granted
# to you to modify and distribute this software under the terms of
# the GNU General Public License and is only of importance to you if
# you choose to contribute your changes and enhancements to the
# community by submitting them to NETWAYS GmbH.)
# 
# By intentionally submitting any modifications, corrections or
# derivatives to this work, or any other work intended for use with
# this Software, to NETWAYS GmbH, you confirm that
# you are the copyright holder for those contributions and you grant
# NETWAYS GmbH a nonexclusive, worldwide, irrevocable,
# royalty-free, perpetual, license to use, copy, create derivative
# works based on those contributions, and sublicense and distribute
# those contributions and any derivatives thereof.
#
# Nagios and the Nagios logo are registered trademarks of Ethan Galstad.


#
# usage: sendMotma.pl <EMAIL-FROM> <EMAIL-TO> <CHECK-TYPE> <DATETIME> <STATUS> <NOTIFICATION-TYPE> <HOST-NAME> <HOST-ALIAS> <HOST-IP> <INCIDENT ID> <AUTHOR> <COMMENT>  <OUTPUT> [SERVICE]
#
#

# TODO: URLize $service
# TODO: Localize Date/Time Field


use strict;
use YAML::Syck;

my $notifierConfig      = '/usr/local/groundwork/noma/etc/NoMa.yaml';
my $conf = LoadFile($notifierConfig);

# check number of command-line parameters
my $numArgs = $#ARGV + 1;
exit 1 if ($numArgs != 13 && $numArgs != 14);


# get parameters
my $from = $ARGV[0];
my $to = $ARGV[1];
my $check_type = $ARGV[2];
my $datetimes = $ARGV[3];
my $status = $ARGV[4];
my $notification_type = $ARGV[5];
my $host = $ARGV[6];
my $host_alias = $ARGV[7];
my $host_address = $ARGV[8];
my $incident_id = $ARGV[9];
my $authors = $ARGV[10];
my $comments = $ARGV[11];
my $output = $ARGV[12];
my $service = '';
my $filename = '';
my $file = '';
my $sendmotma = "/opt/motma/bin/NoMaEvent.pl";
my $subject = 'NoMa Alert';
my $message = "$host/$service is $status\n$output\n";
my $datetime = scalar(localtime($datetimes));

$service = $ARGV[13] if ($numArgs == 14);


# check email format

$from = $from;
$to = $to;


if ($check_type eq 'h')
{
    $subject = $conf->{methods}->{sendmotma}->{message}->{host}->{subject} if (defined( $conf->{methods}->{sendmotma}->{message}->{host}->{subject}));
    if (($authors ne '') or ($comments ne ''))
    {
        $message = $conf->{methods}->{sendmotma}->{message}->{host}->{ackmessage} if (defined( $conf->{methods}->{sendmotma}->{message}->{host}->{ackmessage}));
    } else {
        $message = $conf->{methods}->{sendmotma}->{message}->{host}->{message} if (defined( $conf->{methods}->{sendmotma}->{message}->{host}->{message}));
    }
    $filename = $conf->{methods}->{sendmotma}->{message}->{host}->{filename} if (defined( $conf->{methods}->{sendmotma}->{message}->{host}->{filename}));
} else {
    $subject = $conf->{methods}->{sendmotma}->{message}->{service}->{subject} if (defined( $conf->{methods}->{sendmotma}->{message}->{service}->{subject}));
    if (($authors ne '') or ($comments ne ''))
    {
        $message = $conf->{methods}->{sendmotma}->{message}->{service}->{ackmessage} if (defined( $conf->{methods}->{sendmotma}->{message}->{service}->{ackmessage}));
    } else {
        $message = $conf->{methods}->{sendmotma}->{message}->{service}->{message} if (defined( $conf->{methods}->{sendmotma}->{message}->{service}->{message}));
    }
    $filename = $conf->{methods}->{sendmotma}->{message}->{service}->{filename} if (defined( $conf->{methods}->{sendmotma}->{message}->{service}->{filename}));
}

$sendmotma = $conf->{methods}->{sendmotma}->{sendmotma} if (defined($conf->{methods}->{sendmotma}->{sendmotma}));

$subject =~ s/(\$\w+)/$1/gee;
$message =~ s/(\$\w+)/$1/gee;

my $result = `$sendmotma -H $host -s $service -m '$subject' -S '$status' -P 'from=$from;to=$to;datetimes=$datetimes;datetime=$datetime;status=$status;host=$host;host_alias=$host_alias;host_address=$host_address;authors=$authors;comments=$comments;output=$output;service=$service'`;

exit 0;
