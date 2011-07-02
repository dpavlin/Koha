#!/usr/bin/perl
use warnings;
use strict;

use CGI;
use JSON;
use lib '..';
use C4::Context;

use Data::Dump qw(dump);

my $query = new CGI;
my $dbh = C4::Context->dbh;

my $sql = qq{
select
	userid,
	cardnumber,
	firstname,
	surname,
	email,
	items.itemnumber,
	biblio.title,
	author,
	barcode
	
from issues
join borrowers on borrowers.borrowernumber = issues.borrowernumber
join items on issues.itemnumber = items.itemnumber 
join biblioitems on items.biblioitemnumber = biblioitems.biblioitemnumber
join biblio on biblioitems.biblionumber = biblio.biblionumber
};

my @where;
my @data;
if ( my $nick = $query->param('nick') ) {
	push @where, 'userid = ?';
	push @data, $nick;
}

if ( my $jmbag = $query->param('jmbag') ) {
	push @where, 'cardnumber = ?';
	push @data, 'S' . sprintf("%010d",$jmbag);
}

die 'need nick=? and/or jmbag=?' unless @data;

$sql .= ' where ' . join(' or ', @where);
warn "# SQL: $sql ",dump(@data);
my $sth = $dbh->prepare($sql);
$sth->execute(@data);

my @rows;
while ( my $row = $sth->fetchrow_hashref ) {
	push @rows, $row;
}

print "Content-type: application/json\r\n\r\n", to_json(\@rows, { utf8 => 1 });

