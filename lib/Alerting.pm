package Alerting;

use strict;
use warnings;
use DBI;
use Data::Dumper;
use MoTMa::Application;
use POSIX qw/strftime/;
use Log::Log4perl qw(:easy);

our $VERSION = $MoTMa::Application::VERSION;

our ($alertingDriver);
our $now;
our $ticketCreated;

my $logger = get_logger();

# Preloaded methods go here.
sub new {
    my $class = shift;
    my $self = {};

    eval {
        my $module = $MoTMa::Application::alertingDriver;
        require $MoTMa::Application::alertingDriver . '.pm';
        $module->import();
        
        my $classname = $MoTMa::Application::alertingDriver;
        
        $alertingDriver = $classname->new();
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

sub save {
    my $self            = shift;
    my $summary         = shift;
    my $detail          = shift;
    
    if (lc($MoTMa::Application::alertingExpirationUnit) eq "s") {
        $ticketCreated->add(seconds => $MoTMa::Application::alertingExpirationTime);
    }
    elsif (lc($MoTMa::Application::alertingExpirationUnit) eq "m") {
        $ticketCreated->add(minutes => $MoTMa::Application::alertingExpirationTime);
    }
    else {
        $ticketCreated->add(minutes => 2);
    }

    if ( $now > $ticketCreated ) {
        $alertingDriver->save($summary, $detail);
    }
}


1;
__END__

=head1 Alerting

Alerting - Perl extension for MoTMa

=head1 SYNOPSIS

  use Alerting;

=head1 DESCRIPTION

This Module has a funtion save() which will alert with the alertingDriver. 

=head2 EXPORT

None by default.

=head1 SEE ALSO

Read the related Modules documentation.

=head1 AUTHOR

Andreas Wenger, E<lt>andreas.wenger@realstuff.chE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2016 by Andreas Wenger

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
