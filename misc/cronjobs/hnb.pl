#!/usr/bin/perl

# curl http://www.hnb.hr/tecajn/f`date +%d%m%y`.dat | ./hnb.pl | sudo mysql koha_ffzg

# http://www.hnb.hr/tecajn/hopiszap.htm

use warnings;
use strict;

my $zag = <>;
chomp $zag;

my ( $broj, $izrada, $dd, $mm, $yyyy, $rows ) = unpack 'A3A8A2A2A4A2', $zag;

warn "# $broj - $izrada - $dd $mm $yyyy - $rows\n";

while(<>) {
	chomp;
	s/(\d+),(\d{6})/$1.$2/gs;
	my ( $sifra, $oznaka, $broj, $kupovni, $srednji, $prodajni ) = unpack 'A3A3A3A15A15A15', $_;
	warn "$sifra|$oznaka|$broj|$kupovni|$srednji|$prodajni|\n";

	my $tecaj = $srednji / $broj;

	print qq{
		INSERT INTO currency SET currency='$oznaka',symbol='$oznaka',rate=$tecaj,active=0
		ON DUPLICATE KEY UPDATE rate=$tecaj ;
	};

}
