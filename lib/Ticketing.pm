package Ticketing;

use strict;
use warnings;
use DBI;
use Data::Dumper;
use MoTMa::Application;
use POSIX qw/strftime/;
use Log::Log4perl qw(:easy);

our $VERSION = $MoTMa::Application::VERSION;

our ($ticketDriver);

my $logger = get_logger();

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
        $logger->fatal(Dumper($@));
        
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
    my $ticketNumber    = shift;

    $logger->info("Running update\n");

    $ticketDriver->update($ticket, $idTicket, $autoClose, $serviceTicket, $ticketNumber);
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

sub getTicket {
    my $self            = shift;
    my $idTicket        = shift;
    my $itsmTicketId    = shift;

    return $ticketDriver->getTicket($idTicket, $itsmTicketId);
}

sub getTicketNumber {
    my $self            = shift;
    my $idTicket        = shift;
    
    return $ticketDriver->getTicketNumber($idTicket);
}

1;
__END__

=head1 NAME

Ticketing - Perl module for MoTMa

=head1 SYNOPSIS

  use Helpdesk;

=head1 DESCRIPTION

This module is a generic module for ticketing systems. It defines abstract functions needed for MoTMa. The specific
ticketing driver should implement these functions.

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
