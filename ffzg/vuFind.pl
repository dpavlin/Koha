#!/usr/bin/perl

use strict;
use warnings;

use CGI;
use JSON;
use FindBin;
use C4::Context;
use Koha::Caches;

my $query = new CGI;

use Data::Dump qw(dump);

my $hash = [];
my $cache = Koha::Caches->get_instance();

my $sql = qq{
	select
		concat_ws('',stocknumber,copynumber) as copynumber,
		itemnumber,
		biblionumber,
		itemcallnumber,
		concat(branchname,' - ',authorised_values.lib) as location,
		holdingbranch,
		notforloan,
		onloan,
		itemnotes as note
	from items
	join authorised_values on (authorised_values.category = 'LOC' and authorised_values.authorised_value = items.location)
	join branches on (holdingbranch = branchcode)
	where biblionumber = ?
};

my $dbh = C4::Context->dbh;
my $sth = $dbh->prepare($sql);

if ( my $biblionumber = $query->param('biblionumber') ) {

	if ( $hash = $cache->get_from_cache( "vuFind-$biblionumber" ) ) {
		warn "# $biblionumber HIT\n";
	} else {
		$sth->execute( $biblionumber );
		while ( my $row = $sth->fetchrow_hashref ) {
			push @$hash, $row;
		}
		warn "# $biblionumber MISS\n";
		$cache->set_in_cache( "vuFind-$biblionumber", $hash, { expiry => 5 * 60 } );
	}
}
print "Content-type: application/json; charset=utf-8\r\n\r\n";
warn $query->remote_addr, " $0 ",dump($hash);
print encode_json $hash;
