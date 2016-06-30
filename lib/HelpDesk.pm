package HelpDesk;

use strict;
use warnings;
use DBI;
use Config::IniFiles;
use Data::Dumper;
use MoTMa::Application;
use POSIX qw/strftime/;

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

# Preloaded methods go here.
sub new {
    my $class = shift;
    my $self = {};

    $dbh = DBI->connect( $MoTMa::Application::dbDsn, $MoTMa::Application::dbUser, $MoTMa::Application::dbPassword, {
        RaiseError => 1 }) or die $DBI::errstr;
                      
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

sub getEventByExcludedTicketState {
    my $self = shift;
    my $excludedState       = shift;
    
    my @row;
    my $second = 0;
    
    my $query = "SELECT * FROM helpdesk WHERE ";
    foreach (@{$excludedState}) {
        $query .= " AND " if $second;
        $query .= "ticketstatus <> '".$_."'";
        $second = 1;
    }
    
    print $query."\n";
    
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
        while ( @row = $sth->fetchrow_array ) {
            print "Row: ".Dumper(@row);
        }
        
        $sth->finish();
        return 1;
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
        # GIBT LEIDER NICH IMMER KORREKTE WERTE
        # PostgreSQL: SELECT currval(pg_get_serial_sequence('tickets','idtickets'));
        $lastId = $dbh->last_insert_id(undef, undef, 'tickets', 'idtickets');
        $lastId2 = $dbh->selectrow_array("SELECT currval(pg_get_serial_sequence('tickets','idtickets'));");
        print "Old: $lastId, New:$lastId2\n" if ($lastId ne $lastId2);
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
The event is correlated as defined in configuratoin

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
    my $query = "SELECT * FROM events JOIN tickets on fk_idtickets = idtickets WHERE  ticketstatus <> ?";
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
        # print "Query: ".$query."\nParameters: ".Dumper(@queryParam)."\n";
        $sth = $dbh->prepare($query);
        $sth->execute(@queryParam);
    };
    if ($@) {
        # Not able to run query
        $sth->finish();
        return (0,0);
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
                    print "TRACE: We have already a Ticket, so adding this event to ticket <$idticket>!\n";
                    $updateTicket = 1;
                }
                else {
                    # This should not happen
                    print "ERROR: fk_idtickets are different - you have two open Tickets for this consolidation!\n";
                }
            }
        }
        else {
            # New Ticket - insert new 
            $idticket = $self->insertTicket('', 'NEW', undef, undef);
        }
        $sth->finish();
    }
    
    # Update Event with ticketid
    if ($idticket > 0) {
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
        print "Wir haben 0 als ticketid????\n";
        return (0, 0, $updateTicket);
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
