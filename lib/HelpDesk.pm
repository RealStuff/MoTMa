package HelpDesk;

use strict;
use warnings;
use DBI;
use Config::IniFiles;
use Data::Dumper;
use MoTMa::Application;

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

our $VERSION = '0.01';

our ($driver, $database, $table, $dsn, $user, $password, $dbh, $sth);

# Preloaded methods go here.
sub new {
    my $class = shift;
    my $self = {};

    $dbh = DBI->connect( $MoTMa::Application::dbDsn, $MoTMa::Application::dbUser, $MoTMa::Application::dbPassword, { RaiseError => 1 })
                      or die $DBI::errstr;
                      
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
	my $message             = shift || '';
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

sub getEventByTicketState {
    my $self = shift;
    my $ticketState = shift;
    
    my @row;
    my $second = 0;
    
    my $query = "SELECT * FROM helpdesk WHERE ticketstatus = ?";

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
        while ( @row = $sth->fetchrow_array ) {
            print "Row: ".Dumper(@row);
        }
        
        $sth->finish();
        return 1;
    }
}

sub getEventByExcludedTicketState {
    my $self = shift;
    my $excludedState = shift;
    
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
