#!/usr/bin/perl

# Move an item from a biblio to another
#
# Copyright 2009 BibLibre
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
use CGI;
use C4::Auth;
use C4::Output;
use C4::Biblio;
use C4::Items;
use C4::Context;
use C4::Koha;
use C4::Branch;


my $query = CGI->new;

my $biblionumber = $query->param('biblionumber');
my $barcode	 = $query->param('barcode');

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "cataloguing/linkitem.tmpl",
                 query => $query,
                 type => "intranet",
                 authnotrequired => 0,
                 flagsrequired => {editcatalogue => 'edit_catalogue'},
                 debug => 1,
                 });

my $biblio = GetMarcBiblio($biblionumber);
$template->param(bibliotitle => $biblio->subfield('245','a'));
$template->param(biblionumber => $biblionumber);

if ($barcode && $biblionumber) { 
    
    # We get the host itemnumber
    my $hostitemnumber = GetItemnumberFromBarcode($barcode);

    if ($hostitemnumber) {
	my $hostbiblionumber = GetBiblionumberFromItemnumber($hostitemnumber);
	my $hostrecord = GetMarcBiblio($hostbiblionumber);

	if ($hostbiblionumber) {
	        my $field = MARC::Field->new(
			773, '', '',
			'w' => $hostbiblionumber,
			'o' => $hostitemnumber,
               		'a' => $hostrecord->subfield('245','a'),
	                'x' => $hostrecord->subfield('245','x')
                );
		$biblio->append_fields($field);

		my $modresult = ModBiblio($biblio, $biblionumber, ''); 
		if ($modresult) { 
			$template->param(success => 1);
		} else {
			$template->param(error => 1,
					 errornomodbiblio => 1); 
		}
	} else {
		$template->param(error => 1,
	        	             errornohostbiblionumber => 1);
	}
    } else {
	    $template->param(error => 1,
			     errornohostitemnumber => 1);

    }
    $template->param(
			barcode => $barcode,  
			hostitemnumber => $hostitemnumber,
		    );

} else {
    $template->param(missingparameter => 1);
    if (!$barcode)      { $template->param(missingbarcode      => 1); }
    if (!$biblionumber) { $template->param(missingbiblionumber => 1); }
}


output_html_with_http_headers $query, $cookie, $template->output;
