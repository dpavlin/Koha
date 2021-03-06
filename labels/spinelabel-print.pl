#!/usr/bin/perl

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

use Modern::Perl;
use CGI qw ( -utf8 );
use C4::Auth;
use C4::Output;

my $scheme = C4::Context->preference('SpineLabelFormat');
my $query  = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => "labels/spinelabel-print.tt",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { catalogue => 1 },
        debug           => 1,
    }
);

my $barcode = $query->param('barcode');

my $dbh = C4::Context->dbh;
my $sth;

my $item;

my $sql = "SELECT * FROM biblio, biblioitems, items 
          WHERE biblio.biblionumber = items.biblionumber 
          AND biblioitems.biblioitemnumber = items.biblioitemnumber 
          AND items.barcode = ?";
$sth = $dbh->prepare($sql);
$sth->execute($barcode);
$item = $sth->fetchrow_hashref;

unless (defined $item) {
  $template->param( 'Barcode' => $barcode );
  $template->param( 'BarcodeNotFound' => 1 );
}

# XXX FFZG #1059 -- dpavlin 2012-02-07 print spine labels

use URI::Escape;

my $ip = $query->remote_addr;

if ( my $station = $query->param('station') ) {

	warn "PRINTED $barcode on $station\n";

	my $insert = $dbh->prepare(qq{
		insert into items_print_log (barcode,itemnumber,station) values (?,?,?)
	});
	$insert->execute( $item->{barcode}, $item->{biblioitemnumber}, $station );

} elsif ( $item ) {

	my $print_data = join(' ',
		$item->{barcode},
		$item->{itemcallnumber},
	);

	print $query->redirect( 'http://printer-zebra.vbz.ffzg.hr/print.cgi?print=' . uri_escape_utf8($print_data) . '&return=' . uri_escape($query->self_url) );
	exit 0;

}

# XXX /FFZG

my $body;

my $data;
while ( my ( $key, $value ) = each(%$item) ) {
    $data->{$key} .= "<span class='field' id='$key'>";

    $value = '' unless defined $value;
    my @characters = split( //, $value );
    my $charnum    = 1;
    my $wordernumber    = 1;
    my $i          = 1;
    foreach my $char (@characters) {
        if ( $char ne ' ' ) {
            $data->{$key} .= "<span class='character word$wordernumber character$charnum' id='$key$i'>$char</span>";
        } else {
            $data->{$key} .= "<span class='space character$charnum' id='$key$i'>$char</span>";
            $wordernumber++;
            $charnum = 1;
        }
        $charnum++;
        $i++;
    }

    $data->{$key} .= "</span>";
}

while ( my ( $key, $value ) = each(%$data) ) {
    $scheme =~ s/<$key>/$value/g;
}

$body = $scheme;

# XXX FFZG

my $url = $query->url;
my $station = $query->param('station');

$body = qq|
<style type="text/css">
#print_button {
	display: none;
}
#printed_label {
	border: 1px solid #aaa;
}
body {
	margin: 1em;
}
</style>

<form action="$url" method="get" autocomplete="off">
Enter another barcode:
<input id=focus_barcode type=text name=barcode autofocus autocomplete="off">
<input type=submit value="Print">
</form>

<h1>Last printed call number for $barcode on $station</h1>

<img id="printed_label" src="http://printer-zebra.vbz.ffzg.hr/$barcode.png">

<script type="text/javascript">
function formfocus() {
	document.getElementById('focus_barcode').focus();
}
window.onload = formfocus;
</script>

|;

# XXX /FFZG

$template->param( autoprint => C4::Context->preference("SpineLabelAutoPrint") );
$template->param( content   => $body );

output_html_with_http_headers $query, $cookie, $template->output;
