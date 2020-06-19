package HelpDesk;

use strict;
use warnings;
use DBI;
use Data::Dumper;
use MoTMa::Application;
use POSIX qw/strftime/;
use Log::Log4perl qw(:easy);

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Helpdesk ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = $MoTMa::Application::VERSION;

our ($driver, $database, $table, $dsn, $user, $password, $dbh, $sth);

my $logger = get_logger();

# Preloaded methods go here.
sub new {
    my $class = shift;
    my $self = {};

    $logger->info("Try to connect to Database...");
    $dbh = DBI->connect( $MoTMa::Application::dbDsn, $MoTMa::Application::dbUser, $MoTMa::Application::dbPassword, {
        RaiseError => 1 }) or die $DBI::errstr;
    $logger->info("... connect to Database OK.");

    bless $self, $class;
    return $self;
}

sub DESTROY {
    $dbh->disconnect();
}

sub createDb {
    print "Opened database successfully\n";

    my $stmt = qq(CREATE TABLE $table
        (idhelpdesk         INTEGER PRIMARY KEY AUTOINCREMENT    NOT NULL,
        ticketnumber       TEXT,
        object             TEXT    NOT NULL,
        parameters         TEXT    NOT NULL,
        message            TEXT    NOT NULL,
        ticketstatus       TEXT    NOT NULL,
        created            TIMESTAMP  NOT NULL,
        modified           TIMESTAMP););
    my $rv = $dbh->do($stmt);
    if ($rv < 0) {
        print $DBI::errstr;
    }
    else {
        print "Table created successfully\n";
    }
}

=item insertEvent()
Insert an Event into the database

Your Parameters are:
    host
    service
    category
    parameters
    priority
    message
    monitoringstatus
    created

=cut
sub insertEvent {
	my $self                = shift;
	my $host                = shift;
	my $service             = shift || '';
	my $category            = shift || '';
	my $parameters          = shift || '';
	my $priority            = shift || '';
	my $message             = shift;
	my $monitoringstatus    = shift;
    my $created             = shift || strftime( '%Y-%m-%d %H:%M:%S', localtime );
	
	my $sth;
	
    my $insert = "INSERT INTO events (host, service, category, priority, parameters, message, monitoringstatus, created)
        VALUES (?,?,?,?,?,?,?,?);";
    eval {
        $sth = $dbh->prepare($insert);
        $sth->execute($host, $service, $category, $priority, $parameters, $message, $monitoringstatus, $created);
    };
    if ($@) {
        $sth->finish();
        return 0;
    }
    else {
        $sth->finish();
        return 1;
    }
}

sub getNewEvents {
    my @row;
    my $query = "SELECT * FROM events WHERE fk_idtickets ISNULL ORDER BY created;";
    eval {
        $sth = $dbh->prepare($query);
        $sth->execute();
    };
    if ($@) {
        $sth->finish();
        print "FEHLER ".Dumper($@);
        return 0;
    }
    else {
        my $events = $sth->fetchall_hashref('idevents');
    	
        $sth->finish();
        return $events;
    }
}

sub getEventByObject {
    my $self = shift;
    my $host = shift;
    my $service = shift;
    
    my @row;
    my $query = "SELECT * FROM events WHERE host = ? AND service = ?";
        
    eval {
        $sth = $dbh->prepare($query);
        $sth->execute($host, $service);
    };
    if ($@) {
        $sth->finish();
        print "FEHLER ".Dumper($@);
        return 0;
    }
    else {
        while ( @row = $sth->fetchrow_array ) {
            print "Row: ".Dumper(@row);
        }
    	
        $sth->finish();
        return 1;
    }
}

sub getTicketsByTicketState {
    my $self                = shift;
    my $ticketState         = shift || '';
    
    my $query = "SELECT * FROM tickets JOIN events on idtickets = fk_idtickets WHERE ticketstatus = ? ORDER BY tickets.created";

    eval {
        $sth = $dbh->prepare($query);
        $sth->execute($ticketState);
    };
    if ($@) {
        $sth->finish();
        print "FEHLER ".Dumper($@);
        return 0;
    }
    else {
        my $tickets = $sth->fetchall_hashref('idtickets');
        
        $sth->finish();
        return $tickets;
    }
}

sub getLastEventFromTicket {
    my $self            = shift;
    my $idticket        = shift;

    my $query = "SELECT * FROM tickets JOIN events on idtickets = fk_idtickets WHERE idtickets = ? ORDER BY idevents DESC LIMIT 1";

    eval {
        $sth = $dbh->prepare($query);
        $sth->execute($idticket);
    };
    if ($@) {
        $sth->finish();
        print "FEHLER ".Dumper($@);
        return 0;
    }
    else {
        my $tickets = $sth->fetchall_hashref('idevents');
        
        $sth->finish();
        return $tickets;
    }
}

sub getIdeventsFromTicket {
    my $self            = shift;
    my $idticket        = shift;

    my $query = "SELECT idevents, created FROM events WHERE fk_idtickets = ? ORDER BY idevents;";

    eval {
        $sth = $dbh->prepare($query);
        $sth->execute($idticket);
    };
    if ($@) {
        $sth->finish();
        print "FEHLER ".Dumper($@);
        return 0;
    }
    else {
        my $events = $sth->fetchall_arrayref();
        
        $sth->finish();
        return $events;
    }
}

sub getTicketNumber {
    my $self            = shift;
    my $idTicket        = shift;

    my $query = "SELECT ticketnumber FROM tickets WHERE idtickets = ?;";

    eval {
        $sth = $dbh->prepare($query);
        $sth->execute($idTicket);
    };
    if ($@) {
        $sth->finish();
        print "FEHLER ".Dumper($@);
        return 0;
    }
    else {
        my ($ticketNumber) = $sth->fetchrow_array();
        
        $sth->finish();
        return $ticketNumber;
    }
}


=item updateTicket()
Beschreibung

Your Parameters are:
    idevent
    newEvents

=cut
sub updateTicket {
    my $self                = shift;
    my $idticket            = shift || 0;
    my $ticketnumber        = shift;
    my $ticketstatus        = shift;
    
    # Update Event with ticketid
    if ($idticket > 0) {
        my $update = "UPDATE tickets SET ticketnumber = ?, ticketstatus = ?, modified = ? WHERE idtickets = ?";
        
        eval {
            $sth = $dbh->prepare($update);
            $sth->execute($ticketnumber, $ticketstatus, strftime( '%Y-%m-%d %H:%M:%S', localtime ), $idticket);
        };
        if ($@) {
            $sth->finish();
            print "FEHLER ".Dumper($@);
            return 0;
        }
        else {
            $sth->finish();
            return 1;
        }
        
        print "Ticket updated\n";
    }
    else {
        print "Wir haben 0 als ticketid????\n";
        return 0;
    }
}

=item insertTicket()
Insert an Ticket into the database

Your Parameters are:
    ticketnumber
    ticketstatus
    created
    modified

=cut
sub insertTicket {
	my $self                = shift;
	my $ticketnumber        = shift || '';
	my $ticketStatus        = shift || '';
	my $created             = shift || strftime( '%Y-%m-%d %H:%M:%S', localtime );
	my $modified            = shift || undef;
	
	my $sth;
    my $lastId;
    my $lastId2;
	
    my $insert = "INSERT INTO tickets (ticketnumber, ticketstatus, created, modified)
        VALUES (?,?,?,?);";
    eval {
        $sth = $dbh->prepare($insert);
        # print "TRACE: $ticketnumber, $ticketStatus, $created, $modified\n";
        $sth->execute($ticketnumber, $ticketStatus, $created, $modified);
        # GIBT LEIDER NICH IMMER KORREKTE WERTE
        $lastId = $dbh->last_insert_id(undef, undef, 'tickets', 'idtickets');
        # PostgreSQL: SELECT currval(pg_get_serial_sequence('tickets','idtickets'));
        #$lastId2 = $dbh->selectrow_array("SELECT currval(pg_get_serial_sequence('tickets','idtickets'));");
        #$logger->info("Old: $lastId, New:$lastId2") if ($lastId ne $lastId2);
    };
    if ($@) {
        $sth->finish();
        return 0;
    }
    else {
        $sth->finish();
        return $lastId;
    }
}

=item createTicket()
Check if there is already a ticket for the event. If not create a Ticket else add the event to the existing ticket.
The event is correlated as defined in the configuration

Your Parameters are:
    idevent
    newEvents
=cut
sub createTicket {
    my $self                = shift;
    my $idevent             = shift;
    my $newEvents           = shift;
    my $idticket            = 0;
    my $itsmTicket          = 0;
    my $updateTicket        = 0;
    
    # Get all related events.
    my $query = "SELECT * FROM events JOIN tickets on fk_idtickets = idtickets WHERE  ticketstatus <> ?
        AND ticketstatus <> 'SUPPRESSED'";
    # Add resolved Ticketstate to query params
    my @queryParam = ($MoTMa::Application::closedHelpdeskState);
    # Add Correlation to query params
    foreach (split(/;/, $MoTMa::Application::correlation)){
        if (exists $newEvents->{$idevent}{$_}) {
            $query .= " AND $_ = ?";
            push(@queryParam, $newEvents->{$idevent}{$_});
        }
    }
    
    # Run Query
    eval {
        $logger->trace("Query: ".$query."\nParameters: ".Dumper(@queryParam));
        $sth = $dbh->prepare($query);
        $sth->execute(@queryParam);
    };
    if ($@) {
        # Not able to run query
        $sth->finish();
        $logger->error("--------------------------- !!!! NOT ABLE TO RUN QUERY !!!!! -------------");
        return (0,0,0);
    }
    else {
        my $rsEvents = $sth->fetchall_hashref('idevents');
        # Check if we have already tickets for this event (correlated)
        if (keys %$rsEvents > 0) {
            foreach my $ideventHasTicket (keys %$rsEvents) {
                # Check if we have already a ticket für this correlated events
                if ($idticket == 0 || $idticket == $rsEvents->{$ideventHasTicket}{fk_idtickets}) {
                    # We found the Ticket so keep idticket
                    $idticket = $rsEvents->{$ideventHasTicket}{fk_idtickets};
                    $itsmTicket = $rsEvents->{$ideventHasTicket}{ticketnumber};
                    if ($rsEvents->{$ideventHasTicket}{ticketstatus} eq 'NEW' || 
                            $rsEvents->{$ideventHasTicket}{ticketstatus} eq 'UPDATE' || 
                            $rsEvents->{$ideventHasTicket}{ticketstatus} eq 'PROCESSING') {
                        $updateTicket = 2;
                    }
                    else {
                        $updateTicket = 1;
                    }
                }
                else {
                    # This should not happen
                    $logger->fatal("fk_idtickets are different - you have two open Tickets for this consolidation!");
                }
            }
        }
        else {
            # We have event to create new ticket - do we have to suppress creation?
            if ($newEvents->{$idevent}{'monitoringstatus'} eq 'OK' ||
                    $newEvents->{$idevent}{'monitoringstatus'} eq 'UP') {
                # Suppress creation of ticket
                $logger->info("Suppression of ticket because its OK/UP");
                $idticket = $self->insertTicket('', 'SUPPRESSED', undef, undef);
            }
            else {
                # Create Ticket
                $idticket = $self->insertTicket('', 'NEW', undef, undef);
            }
        }
        $sth->finish();
    }
    
    # Update Event with ticketid
    if ($updateTicket == 2) {
        $logger->info("Do not update Ticket because we have a ticket motma is working on (NEW, UPDATE or PROCESSING)");
        return ($idticket, $itsmTicket, $updateTicket);
    }
    elsif ($idticket > 0) {
        $logger->info("We have already a Ticket, so adding this event to ticket <$idticket>!") if $updateTicket;
        my $update = "UPDATE events SET fk_idtickets = ? WHERE idevents = ?";
        eval {
            $sth = $dbh->prepare($update);
            $sth->execute($idticket, $idevent);
        };
        if ($@) {
            # Update not successfully
            $sth->finish();
            return (0, 0, $updateTicket);
        }
        else {
            $sth->finish();
            # Event is added to Ticket.
            return ($idticket, $itsmTicket, $updateTicket);
        }
    }
    else {
        return (0, 0, $updateTicket);
    }
}

1;
__END__

=head1 NAME

Helpdesk - Perl extension to access the MoTMa database.

=head1 SYNOPSIS

  use Helpdesk;

=head1 DESCRIPTION

Helpdesk is the module to access the MoTMa database.

=head2 EXPORT

None by default.



=head1 SEE ALSO

To have an idea what this module does, look also on the documenations of each function.

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
