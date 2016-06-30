package Ticketing;

use strict;
use warnings;
use DBI;
use Config::IniFiles;
use Data::Dumper;
use MoTMa::Application;
use POSIX qw/strftime/;

our $VERSION = $MoTMa::Application::VERSION;

our ($ticketDriver);

# Preloaded methods go here.
sub new {
    my $class = shift;
    my $self = {};

    eval {
        my $module = $MoTMa::Application::ticketDriver;
        require $MoTMa::Application::ticketDriver . '.pm';
        $module->import();
        
        my $classname = $MoTMa::Application::ticketDriver;
        
        $ticketDriver = $classname->new();
        1;
    };
    if ($@) {
        print "FEHLER ".Dumper($@);
        
        # Muss noch schlau beendet werden
        
        return 0;
    }
    
    
    bless $self, $class;
    return $self;
}

sub DESTROY {
    
}

sub update {
    my $self            = shift;
    my $ticket          = shift;
    my $idTicket        = shift;
    my $autoClose       = shift || 0;
    my $serviceTicket   = shift;

    $ticketDriver->update($ticket, $idTicket, $autoClose, $serviceTicket);
}

sub create {
    my $self            = shift;
    my $ticket          = shift;
    my $idTicket        = shift;
    my $serviceTicket   = shift;
    
    return $ticketDriver->create($ticket, $idTicket, $serviceTicket);
}

sub get {
    my $self            = shift;
    my $idTicket        = shift;
    my $itsmTicketId    = shift;
    
    return $ticketDriver->get($idTicket, $itsmTicketId);
}

sub getTicketNumber {
    my $self            = shift;
    my $idTicket        = shift;
    
    return $ticketDriver->getTicketNumber($idTicket);
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
