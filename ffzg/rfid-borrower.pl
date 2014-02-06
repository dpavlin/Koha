#!/usr/bin/perl

# Copyright Dobrica Pavlinusic 2014
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
use warnings;

use CGI;
use C4::Context;
use JSON;

my $query = new CGI;
print "Content-type: application/json; charset=utf-8\r\n\r\n";

my $dbh = C4::Context->dbh;
my $json;

my @where;
my @execute;

foreach my $name (qw( OIB JMBAG RFID_SID )) {
	if ( my $val = $query->param($name) ) {
		$json->{param}->{$name} = $val;
		push @where, "( code = '$name' and attribute = ? )";
		push @execute, $val;
	}
}

my $sql = qq{
select
	distinct
	b.borrowernumber, firstname, surname, email, userid, cardnumber
from borrower_attributes ba
join borrowers b on b.borrowernumber = ba.borrowernumber
where (} . join(') or (', @where) . qq{)};

warn "# sql $sql\n";

my $sth = $dbh->prepare( $sql );
$sth->execute( @execute );

$json->{rows} = $sth->rows;

if ( $sth->rows < 1 ) {
	$json->{error} = "borrower not found";
} elsif ( $sth->rows > 1 ) {
	$json->{error} = "more than one borrower found";
} else {
	$json->{borrower} = $sth->fetchrow_hashref;
}

$json = encode_json( $json );
if ( my $callback = $query->param('callback') ) {
	print $callback, '(', $json, ')';
} else {
	print $json;
}
