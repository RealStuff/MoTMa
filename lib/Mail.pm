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
    

    print "Will schicken...\n";
    # my $to = 'andreas.wenger@realstuff.ch';
    # # my $cc = 'andreas.wenger@realstuff.ch';
    # my $from = 'andreas.wenger@realstuff.ch';
    # my $subject = 'Test Email';

    my $msg = MIME::Lite->new(
        From     => $MoTMa::Application::alertingFrom,
        To       => $MoTMa::Application::alertingTo,
        # Cc       => $cc,
        Subject  => $subject,
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
