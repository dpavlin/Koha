#!/usr/bin/perl

use warnings;
use strict;

use Net::LDAP;
use DBI;
use Data::Dump qw(dump);

my $debug = $ENV{DEBUG} || 0;

my $forever = '2025-12-31';

our $dsn      = 'DBI:mysql:dbname=';
our $database = 'koha';
our $user     = 'kohaadmin';
our $passwd   = 'password';

require 'config.pl';

my $dbh = DBI->connect($dsn . $database, $user,$passwd, { RaiseError => 1, AutoCommit => 0 }) || die $DBI::errstr;

my $sth = $dbh->prepare(q{
select
	userid,
	dateexpiry,
	b.borrowernumber,
	a.borrowernumber as have_oib,
	attribute as oib
from borrowers b
left outer join borrower_attributes a
	on b.borrowernumber = a.borrowernumber and code='OIB'
where userid like '%@ffzg.hr'
order by userid
});

$sth->execute();
my $rows = $sth->rows;

warn "updating on $rows borrowers\n";

my $update_dateexpiry = $dbh->prepare(q{
update borrowers
set dateexpiry = ?
where userid = ?
});

my $insert_oib = $dbh->prepare(q{
        insert into borrower_attributes (borrowernumber,code,attribute)
        values (?,'OIB',?)
});

my $update_oib = $dbh->prepare(q{
        update borrower_attributes
        set attribute = ?
        where borrowernumber = ? and code='OIB'
});

my $update_userid = $dbh->prepare(q{
update borrowers
set userid = ?
where borrowernumber = ?
});


#my $ldap = Net::LDAP->new( 'localhost:1389' );
my $ldap = Net::LDAP->new( 'ldaps://ldap.ffzg.hr' );

my $bind = $ldap->bind;
die $bind->error if $bind->code;

sub search {
	my $id = shift;
	my $search = $ldap->search( base => 'dc=ffzg,dc=hr', filter => 'HrEduPersonUniqueID=' . $id );
	die $search->error if $search->code;

	my @entries = $search->entries;

	if ( ! @entries ) {
		print "ERROR $id not in found in LDAP\n";
		return;
	}

	$entries[0]->dump if $debug;
	return @entries;
}

my $nr = 0;
my $fmt = "%-5s  %-20s %10s %s %-10s %d/%d %.2f%% %s\n";

while (my $row = $sth->fetchrow_hashref) {

	$nr++;

	my @pos = ( $nr, $rows, ( $nr * 100 ) / $rows );

	my @entries = search( $row->{userid} );
	if ( ! @entries ) {
		my $userid = $row->{userid};
		$userid =~ s{\@ffzg.hr}{\@expired} || die "can't change userid";
		$update_userid->execute( $userid, $row->{borrowernumber} );
		$update_dateexpiry->execute( 'date(now())', $row->{userid} );
		printf $fmt, 'EXPIRED', $row->{userid}, $row->{dateexpiry}, '  ', '', @pos;
		next;
	}

	my $oib       = $entries[0]->get_value( 'hrEduPersonOIB' );
	if ( ! $row->{oib} && $oib && ! $row->{have_oib} ) {
		$insert_oib->execute( $row->{borrowernumber}, $oib );
		$oib = "++ $oib";
	} elsif ( $row->{oib} ne $oib ) {
		$update_oib->execute( $oib, $row->{borrowernumber} );
		$oib = join(' ', $row->{oib}, '>>', $oib);
	} elsif ( $row->{oib} eq $oib ) {
		$oib = "OK $oib";
	} else {
		die dump( $row->{oib}, $oib );
	}
	push @pos, $oib;

	my $ldap_date = $entries[0]->get_value( 'hrEduPersonExpireDate' );
	$ldap_date =~ s/^(\d\d\d\d)(\d\d)(\d\d)$/$1-$2-$3/;

	if ( $ldap_date eq $row->{dateexpiry} ) {
		printf $fmt, 'ok', $row->{userid}, $row->{dateexpiry}, '  ', '', @pos;
	} elsif ( $ldap_date eq 'NONE' && $row->{dateexpiry} ne $forever ) {
		printf $fmt, 'none', $row->{userid}, $ldap_date, '>>', $forever, @pos;
		$update_dateexpiry->execute( $forever, $row->{userid} );
	} elsif ( $ldap_date !~ m/\d+\d\d\d-\d\d-\d\d/ ) {
		printf $fmt, 'SKIP', $row->{userid}, $row->{dateexpiry}, '!!', $ldap_date, @pos;
	} elsif ( $ldap_date && $row->{dateexpiry} ne $ldap_date ) {
		printf $fmt, 'update', $row->{userid}, $row->{dateexpiry}, '->', $ldap_date, @pos;
		$update_dateexpiry->execute( $ldap_date, $row->{userid} );
	} else {
		die dump( $ldap_date, $row );
	}


}

$dbh->commit if ! $debug;

