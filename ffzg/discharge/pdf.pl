#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright 2013 BibLibre
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

use Modern::Perl;
use Carp;

use C4::Auth qw(:DEFAULT get_session);
use CGI qw( -utf8 );
use C4::Context;
use C4::Output;
use C4::Log;
use C4::Debug;
use Koha::Patrons;
use Koha::Patron::Discharge;
use Koha::DateUtils;

my $input = new CGI;

unless ( C4::Context->preference('useDischarge') ) {
    exit;
}

my $borrowernumber = $input->param("borrowernumber") // '';

my $can_be_discharged = Koha::Patron::Discharge::can_be_discharged({ borrowernumber => $borrowernumber });
my $pending = Koha::Patron::Discharge::count({
    borrowernumber => $borrowernumber,
    pending        => 1,
});
my $available = Koha::Patron::Discharge::is_discharged({borrowernumber => $borrowernumber});

use Data::Dump qw(dump);
warn "XXX borrowernumber = $borrowernumber can_be_discharged = $can_be_discharged pending = $pending available = $available";

if ( $pending || ! $available || ! $can_be_discharged ) {
	print $input->header( -type       => 'text/plain' );
	print "borrowernumber = $borrowernumber can_be_discharged = $can_be_discharged pending = $pending available = $available";
	exit;
}

        # Getting member data
        my $patron = Koha::Patrons->find( $borrowernumber );
        my $pdf_path = Koha::Patron::Discharge::generate_as_pdf({
            borrowernumber => $borrowernumber,
            branchcode => $patron->branchcode,
        });

        binmode(STDOUT);
        print $input->header(
            -type       => 'application/pdf',
            -charset    => 'utf-8',
            -attachment => "discharge_$borrowernumber.pdf",
        );
        open my $fh, '<', $pdf_path;
        my @lines = <$fh>;
        close $fh;
        print @lines;

        exit;

