#!/usr/bin/perl
use warnings;
use strict;
use autodie;
use Data::Dump qw(dump);

use MARC::Record;

$|=1;
use lib '/srv/koha_gimpoz/';

BEGIN {
	$ENV{KOHA_CONF} = '/etc/koha/sites/gimpoz/koha-conf.xml';
}
use C4::Images;
use C4::Biblio;
use C4::Items;

my $source_dir = '/data/gimpoz/import';
my $replace = 0;
my $frameworkcode = '';

my $biblionumber;

open(my $find, '-|', qq{find $source_dir -iname "*.jpg" | sort});
while(<$find>) {
	chomp;
#	next unless m/\s*-\s*([a-k])\s*/i ;
	my $path = $_;
	warn "# path $path\n";
	s{^\Q$source_dir\E/*}{};
	my $uri = $_;
	my $student = $1 if s{^(.+?)/}{};
	$student =~ s/^(\d+).*/$1/;
	my $lokacija = $1 if s{^(.+?)/}{};

	my $inventarni_broj = $_;
	$inventarni_broj =~ s/\.jpg$//i;

	if ( $inventarni_broj =~ m/\s*-\s*([b-k])\s*$/i ) {
		warn "# $biblionumber dio $1\n";
	} else {
		$inventarni_broj =~ m/\s*-\s*a\s*$/i; # remove first -a
		my $record = MARC::Record->new;
		$record->add_fields(
			[ 245, " ", " ", a => $inventarni_broj ],
			[ 942, " ", " ", c => "NO" ],
			[ 952, " ", " ", a => "GIMPOZ" ],
			[ 952, " ", " ", b => "GIMPOZ" ],
			[ 952, " ", " ", c => uc(substr($lokacija,0,1)) ],
			[ 952, " ", " ", t => $inventarni_broj ],
			[ 952, " ", " ", u => $uri ], # FIXME
		);

		warn $record->as_formatted;

		my $biblioitemnumber;
		($biblionumber,$biblioitemnumber) = AddBiblio($record,$frameworkcode);
		warn "# AddBiblio $biblionumber $biblioitemnumber [$inventarni_broj]\n";

		my ($biblionumber, $biblioitemnumber, $itemnumber)
			= AddItemFromMarc($record, $biblionumber);

		warn "# AddItemFromMarc $biblionumber $biblioitemnumber $itemnumber\n";

	}

	my $image = GD::Image->new($path);
	warn "# $path ", $image->width,"x",$image->height,$/;
	PutImage($biblionumber, $image, $replace);

	print dump( $biblionumber, $student, $lokacija, $inventarni_broj ),$/;
}

