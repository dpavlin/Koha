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

my $source_dir = '/data/gimpoz/dvd1';
my $replace = 1;
my $frameworkcode = '';

sub marc {
	my $marc = {@_};
	print "MARC ",dump($marc),$/;
}

my $biblionumber;

open(my $find, '-|', qq{find $source_dir -iname "*.jpg" | sort});
while(<$find>) {
	chomp;
	my $path = $_;
	warn "# path $path\n";
	s{^\Q$source_dir\E/*}{};
	my $student = $1 if s{^(.+?)/}{};
	$student =~ s/^(\d+).*/$1/;
	my $lokacija = $1 if s{^(.+?)/}{};

	my $inventarni_broj = $_;
	$inventarni_broj =~ s/\.jpg$//i;

	if ( $inventarni_broj =~ m/\s*-\s*([a-k])\s*$/i ) {
		warn "# $biblionumber dio $1\n";
	} else {
		my $record = MARC::Record->new;
		$record->add_fields(
			[ 245, " ", " ", a => $inventarni_broj ],
			[ 952, " ", " ", t => $inventarni_broj ],
		);

		my $biblioitemnumber;
		($biblionumber,$biblioitemnumber) = AddBiblio($record,$frameworkcode);
		warn "# AddBiblio $biblionumber $biblioitemnumber [$inventarni_broj]\n";

		my ($biblionumber, $biblioitemnumber, $itemnumber)
			= AddItemFromMarc($record, $biblionumber);

		warn "# AddItemFromMarc $biblionumber $biblioitemnumber $itemnumber\n";

	}

	my $image = GD::Image->new($path);
	PutImage($biblionumber, $image, $replace);

	print dump( $biblionumber, $student, $lokacija, $inventarni_broj ),$/;
}

