#!/usr/bin/perl

#example script to print a basketgroup
#written 07/11/08 by john.soros@biblibre.com and paul.poulain@biblibre.com

# Copyright 2008-2009 BibLibre SARL
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

#you can use any PDF::API2 module, all you need to do is return the stringifyed pdf object from the printpdf sub.
package pdfformat::ffzg;
use vars qw($VERSION @ISA @EXPORT);
use MIME::Base64;
use List::MoreUtils qw/uniq/;
use strict;
use warnings;
use utf8;

use Koha::Number::Price;
use Koha::DateUtils;

use Data::Dump qw(dump); # FIXME

BEGIN {
         use Exporter   ();
         our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);
	# set the version for version checking
         $VERSION     = 1.00;
	@ISA    = qw(Exporter);
	@EXPORT = qw(printpdf);
}


#be careful, all the sizes (height, width, etc...) are in mm, not PostScript points (the default measurment of PDF::API2).
#The constants exported transform that into PostScript points (/mm for milimeter, /in for inch, pt is postscript point, and as so is there only to show what is happening.
use constant mm => 25.4 / 72;
use constant in => 1 / 72;
use constant pt => 1;

use PDF::API2;
#A4 paper specs
my ($height, $width) = (297, 210);
use PDF::Table;

sub _pdf_font {
	my ($pdf, $font) = @_;
	# $font = Times, Times-Bold

	my $mapping = {
		'Times'      => '/usr/share/fonts/truetype/dejavu/DejaVuSansCondensed.ttf',
		'Times-Bold' => '/usr/share/fonts/truetype/dejavu/DejaVuSansCondensed-Bold.ttf',
	};

	if ( my $ttf = $mapping->{$font} ) {
#		warn "XXX using $ttf font insted of $font";
		return $pdf->ttfont( $ttf );

	} else {
		warn "ERROR: can't find ttf font $font, fallback to corefont";
		return $pdf->corefont($font, -encoding => "utf8");
	}

}


sub printhead {
    my ($pdf, $basketgroup, $bookseller) = @_;

    # get library name
    my $libraryname = C4::Context->preference("LibraryName");
    # get branch details
    my $freedeliveryplace = $basketgroup->{freedeliveryplace};
warn "XXX freedeliveryplace = ", dump($freedeliveryplace);

    # open 1st page (with the header)
    my $page = $pdf->openpage(1);

    # create a text
    my $text = $page->text;
	$text->fillcolor('black');
#	$text->fillcolor('red');


    # print order info, on the default PDF
    $text->font( _pdf_font( $pdf, "Times-Bold" ), 12/pt );
#    $text->translate(100/mm,  ($height-24)/mm);
	$text->translate(283/pt, 774/pt);
	$text->text( $basketgroup->{'id'} . '-' . $basketgroup->{'ffzg_nr'} . '/' . $basketgroup->{'ffzg_year'} );

    $text->font( _pdf_font( $pdf, "Times" ), 10/pt );

    # print the date FIXME
#    $text->translate(140/mm,  ($height-24)/mm);
    $text->translate(420.75/pt,  773.93/pt);
    $text->text($basketgroup->{ffzg_date});

#warn "XXX bookseller ", dump( $bookseller );

    # print bookseller infos
	my $y_pt = 727;
	foreach my $line ( $bookseller->{name}, split(/[\n\r]+/, $bookseller->{postal}) ) {
	    $text->translate(336/pt, $y_pt/pt);
		$text->text($line);
		$y_pt -= 12;
	}

	# Lokacija za isporuku -- Zbirka...
    $text->translate(62/pt, 590/pt);
    $text->text($basketgroup->{deliverycomment});

    $text->translate(58/pt, 556/pt);
    $text->text("Narudžbenicu ispisala: " . C4::Context->userenv->{"firstname"} . " " .  C4::Context->userenv->{"surname"} );
#    $text->translate(58/pt, 556/pt - 10/pt);
#	$text->text("basketgroup: " . $basketgroup->{'id'});

}

sub print_tables {
    my ($pdf, $basketgroup, $baskets, $orders) = @_;

    my $cur_format = C4::Context->preference("CurrencyFormat");

	my $a_titles = [[
		'Rbr.',
		'košarica / narudžba',
		'Naslov',
		'Kol.',
		'Cijena bez PDV-a',
		'Cijena s PDV-om',
		'Popust %',
		'Popust iznos',
		'Porez',
		'Ukupno bez PDV-a',
		'Ukupno s PDV-om'
	]];

	my $rbr = 1;

	my $order_total;
	my $basket_totals;

    for my $basket (@$baskets){

#warn "XXX basket = ",dump( $basket );

		my $basket_total;

        my $titleinfo;
        foreach my $order (@{$orders->{$basket->{basketno}}}) {
#warn "XXX order = ",dump($order);

			$order->{discount_value} = $order->{rrpgste} - $order->{ecostgste};
			$basket_total->{$_} += $order->{$_} foreach (qw( totalgste totalgsti gstvalue quantity ));
			$basket_total->{$_} += $order->{$_} * $order->{quantity} foreach (qw( rrpgste rrpgsti ecostgste discount_value ));
			push @{$basket_total->{gstrate}}, $order->{gstrate};

            $titleinfo = "";
            if ( C4::Context->preference("marcflavour") eq 'UNIMARC' ) {
                $titleinfo =  $order->{title} . " / " . $order->{author} .
                    ( $order->{isbn} ? " ISBN: " . $order->{isbn} : '' ) .
                    ( $order->{en} ? " EN: " . $order->{en} : '' ) .
                    ( $order->{itemtype} ? ", " . $order->{itemtype} : '' ) .
                    ( $order->{edition} ? ", " . $order->{edition} : '' ) .
                    ( $order->{publishercode} ? ' published by '. $order->{publishercode} : '') .
                    ( $order->{publicationyear} ? ', '. $order->{publicationyear} : '');
            }
            else { # MARC21, NORMARC
                $titleinfo =  $order->{title} . " " . $order->{author} .
                    ( $order->{isbn} ? " ISBN: " . $order->{isbn} : '' ) .
                    ( $order->{en} ? " EN: " . $order->{en} : '' ) .
                    ( $order->{itemtype} ? " " . $order->{itemtype} : '' ) .
                    ( $order->{edition} ? ", " . $order->{edition} : '' ) .
                    ( $order->{publishercode} ? ' published by '. $order->{publishercode} : '') .
                    ( $order->{copyrightdate} ? ' '. $order->{copyrightdate} : '');
            }

            push @$a_titles, [
				$rbr++ . '.',
				$basket->{basketno} . ' / ' . $order->{ordernumber},
                $titleinfo, #. ($order->{order_vendornote} ? "\n----------------\nNote for vendor : " . $order->{order_vendornote} : '' ),
                $order->{quantity},
                Koha::Number::Price->new( $order->{rrpgste} )->format,
                Koha::Number::Price->new( $order->{rrpgsti} )->format,
                Koha::Number::Price->new( $order->{discount} )->format . '%',
                Koha::Number::Price->new( $order->{discount_value})->format,
                Koha::Number::Price->new( $order->{gstrate} * 100 )->format . '%',
                Koha::Number::Price->new( $order->{totalgste} )->format,
                Koha::Number::Price->new( $order->{totalgsti} )->format,
            ];
        }

		$basket_total->{$_} = $basket->{$_} foreach qw( basketname basketno );
		$basket_total->{gstrate} = join(" ", map { Koha::Number::Price->new($_ * 100)->format . '%' } uniq @{ $basket_total->{gstrate} } );

		push @$basket_totals, $basket_total;

		$order_total->{$_} += $basket_total->{$_} foreach qw( rrpgste rrpgsti totalgste totalgsti gstvalue quantity ecostgste discount_value );
		push @{$order_total->{gstrate}}, $basket_total->{gstrate};
    }

	$order_total->{gstrate} = join(" ", uniq @{ $order_total->{gstrate} } );

warn "XXX basket_totals = ",dump( $basket_totals );
warn "XXX order_total = ", dump( $order_total );

	push @$a_titles, [
		'',
		'',
		'Ukupno:',
		$order_total->{quantity},
		Koha::Number::Price->new( $order_total->{rrpgste} )->format,
		Koha::Number::Price->new( $order_total->{rrpgsti} )->format,
		'', # discount
		Koha::Number::Price->new( $order_total->{discount_value})->format,
		'', # gstrate
		Koha::Number::Price->new( $order_total->{totalgste} )->format,
		Koha::Number::Price->new( $order_total->{totalgsti} )->format,
	];

	my $a_baskets = [[
		'Br. košarice',
	'Košarica',
		'Cijena bez PDV-a',
		'Cijena s PDV-om',
		'Porez',
		'Iznos poreza',
		'Popust iznos',
		'Ukupno bez PDV-a',
		'Ukupno s PDV-om',
	]];
	foreach my $basket_total ( @$basket_totals ) {
		push @$a_baskets, [ map {
				m/^basket/
				? $basket_total->{$_}
				: Koha::Number::Price->new($basket_total->{$_})->format . ( m/^gstrate$/ ? '%' : '' )
			} qw(
			basketno
			basketname
			rrpgste
			rrpgsti
			gstrate
			gstvalue
			discount_value
			totalgste
			totalgsti
		) ];
	}
	push @$a_baskets, [ '', 'Ukupno', map { Koha::Number::Price->new($order_total->{$_})->format } qw(
		rrpgste
		rrpgsti
		gstrate
		gstvalue
		discount_value
		totalgste
		totalgsti
	) ];
	$a_baskets->[-1]->[4] = ''; # remove gstreate from total

    $pdf->mediabox($height/mm, $width/mm);
	my $page = $pdf->openpage(1);
	my $pdftable = new PDF::Table();

	my ($end_page, $pages_spanned, $table_bot_y) =
	$pdftable->table($pdf, $page, $a_titles,
		x => 10/mm, # 57/pt
		w => ($width - 20)/mm,
		start_y => 470/pt,
		next_y  => $height/mm - 25/mm,
		start_h => $height/mm - 470/pt, # - 25/mm,
		next_h  => $height/mm - ( 2 * 25/mm ),
		padding => 3,
		padding_top => 2,
		background_color_odd  => "lightgray",
		font       => _pdf_font( $pdf, "Times" ),
		font_size => 8/pt,
		header_props   =>    {
			font       => _pdf_font( $pdf, "Times" ),
			font_size  => 8/pt,
			font_color => 'white',
			bg_color   => 'gray',
			repeat     => 1,
		},
		column_props => [
			{}, # rbr
			{}, # basket/order
			{ min_w => 55/mm },
			{ justify => 'right' },
			{ justify => 'right' },
			{ justify => 'right' },
			{ justify => 'right' },
			{ justify => 'right' },
			{ justify => 'right' },
			{ justify => 'right' },
			{ justify => 'right' },
		],
	);

	$table_bot_y -= 10/mm;

	if ( $table_bot_y < 25/mm + ( 3 + @$a_baskets ) * 12/pt ) {
		warn "XXX force baskets to next page\n";
		$table_bot_y = $height/mm - 25/mm;
		$end_page = $pdf->page();
	}

	my $text = $end_page->text;
	$text->font( _pdf_font( $pdf, "Times" ), 10/pt );
	$text->translate(20/mm, $table_bot_y );
#	$text->fillcolor('red');
	$text->text("Trošak po košaricama");

	$table_bot_y -= 5/mm;
	$page = $end_page;

	$pdftable->table($pdf, $page, $a_baskets,
		x => 10/mm, # 57/pt
		w => ($width - 20)/mm,
		start_y => $table_bot_y,
		next_y  => 250/mm,
		start_h => 250/mm,
		next_h  => 250/mm,
		padding => 3,
		padding_top => 2,
		background_color_odd  => "lightgray",
		font       => _pdf_font( $pdf, "Times" ),
		font_size => 8/pt,
		header_props   =>    {
			font       => _pdf_font( $pdf, "Times" ),
			font_size  => 8/pt,
			font_color => 'white',
			bg_color   => 'gray',
			repeat     => 1,
		},
		column_props => [
			{},
			{},
			{ justify => 'right' },
			{ justify => 'right' },
			{ justify => 'right' },
			{ justify => 'right' },
			{ justify => 'right' },
			{ justify => 'right' },
			{ justify => 'right' },
		],
	);

}
sub printfooters {
	my ($pdf, $basketgroup) = @_;
	for (my $i=1;$i <= $pdf->pages;$i++) {
		my $page = $pdf->openpage($i);
		my $text = $page->text;
		$text->font( _pdf_font( $pdf, "Times" ), 3/mm );
		$text->translate(10/mm,  10/mm);
		$text->text("Page $i / ".$pdf->pages);
#		$text->text("Page $i / ".$pdf->pages . "    basketgroup: " . $basketgroup->{id});
		$text->translate($width/mm - 40/mm,  10/mm);
		$text->text("basketgroup: " . $basketgroup->{id});
	}
}

sub printpdf {
    my ($basketgroup, $bookseller, $baskets, $orders, $GST) = @_;
warn "XXX basketgroup = ",dump($basketgroup);

	if ( ! $basketgroup->{ffzg_year} ) {
		if ( $basketgroup->{ffzg_date} =~ m/^(\d\d\d\d)-(\d\d)-(\d\d)\s.*/ ) {
			my ( $yyyy, $mm, $dd ) = ( $1, $2, $3 );
			my $dbh = C4::Context->dbh;
			$dbh->begin_work;
			my $sth = $dbh->prepare(qq{ select max(ffzg_nr) from aqbasketgroups where ffzg_year = ? });
			$sth->execute( $yyyy );
			my ($nr) = $sth->fetchrow_array;
			$nr++;
			$sth = $dbh->prepare(qq{ update aqbasketgroups set ffzg_year = ?, ffzg_nr = ? where id = ? });
			$sth->execute( $yyyy, $nr, $basketgroup->{id} );

			$dbh->commit;
			warn "XXX ",$basketgroup->{id}, " basketgroup got $yyyy-$nr\n";

			$basketgroup->{ffzg_year} = $yyyy;
			$basketgroup->{ffzg_nr}   = $nr;
		}
	}

	$basketgroup->{ffzg_date} =~ s/\s.+//; # strip time from datetime

    # open the default PDF that will be used for base (1st page already filled)
    my $pdf_template = C4::Context->config('intrahtdocs') . '/' . C4::Context->preference('template') . '/pdf/ffzg-narudzbenica.pdf';
    my $pdf = PDF::API2->open($pdf_template);
    $pdf->pageLabel( 0, {
        -style => 'roman',
    } ); # start with roman numbering
    # fill the 1st page (basketgroup information)
    printhead($pdf, $basketgroup, $bookseller);

    print_tables($pdf, $basketgroup, $baskets, $orders);


    # print something on each page (usually the footer, but you could also put a header
    printfooters($pdf, $basketgroup);
    return $pdf->stringify;
}

1;
