#!/usr/bin/perl
use strict;
use warnings;

use Test::More tests => 2;
use Data::Dump qw(dump);

BEGIN { use_ok('Koha::Persistant'); }

ok my $row = Koha::Persistant::authorised_value( category => 'WITHDROWN', 1 ), 'authorised_value';
diag dump $row;

diag dump $Koha::Persistant::stats;
