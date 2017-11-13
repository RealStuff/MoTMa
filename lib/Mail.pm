package Mail;

use strict;
use warnings;
use DBI;
use Data::Dumper;
use MoTMa::Application;
use POSIX qw/strftime/;
use MIME::Lite;

our $VERSION = $MoTMa::Application::VERSION;

# Preloaded methods go here.
sub new {
    my $class = shift;
    my $self = {};
    
    bless $self, $class;
    return $self;
}

sub DESTROY {
    
}

sub save {
    my $self        = shift;
    my $subject     = shift;
    my $message     = shift;

    my $msg = MIME::Lite->new(
        From     => $MoTMa::Application::alertingFrom,
        To       => $MoTMa::Application::alertingTo,
        # Cc       => $cc,
        Subject  => $MoTMa::Application::alertingSubject.$subject,
        Data => $message,
    );

    if ($MoTMa::Application::alertingSmtp ne '') {
        $msg->send('smpt', $MoTMa::Application::alertingSmtp);
    }
    else {
        $msg->send()
    }
}

1;
__END__

=head1 NAME

Mail - Perl module to wrap arround e-mail notifications.

=head1 SYNOPSIS

  use Mail;

=head1 DESCRIPTION

Mail.pm is one of the first alerting drivers in MoTMa. You can use this module to alert if there are problems with
communicationg to your ticketing application.

The configuration of this module is done by the motma.ini config file. To activate mail alerting you should define
in section global:

[global]
    ...
    alertingDriver = Mail
    ...

and add also an additional section Mail to configure the alertingDriver Mail:

[Mail]
    from = root@localhost
    to = root@localhost

=head2 EXPORT

None by default.

=head1 SEE ALSO

This module is using MIME::Lite. Please look at this to get the details about sending.

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
