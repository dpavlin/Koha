#!/usr/bin/perl
use strict;
use warnings;

use Test::More tests => 10;
use Data::Dump qw(dump);

BEGIN { use_ok('Koha::Persistant'); }

ok my $row = Koha::Persistant::authorised_value( category => 'WITHDROWN', 1 ), 'authorised_value';
ok $row->{lib}, 'lib';
ok $row->{lib_opac}, 'lib_opac';
diag dump $row;

foreach ( 1 .. 3 ) {
	is_deeply Koha::Persistant::authorised_value( category => 'WITHDROWN', 1 ), $row, "authorised_value cached $_";
}

is_deeply my $stats = $Koha::Persistant::stats, { authorised_value => [3, 1] }, 'stats correct';
diag dump $stats;

ok my $_cache = $Koha::Persistant::_cache, '_cache';
diag dump $_cache;

ok my $_sql_cache = $Koha::Persistant::_sql_cache, '_sql_cache';
diag dump $_sql_cache;
