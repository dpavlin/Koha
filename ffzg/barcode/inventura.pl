#!/usr/bin/perl

use Modern::Perl;

use C4::Context;
use C4::Circulation;
use Data::Dump qw(dump);
use CGI qw ( -utf8 );

binmode STDOUT, ':encoding(UTF-8)';

my $q = new CGI;

my $barcode = $q->param('barcode');
warn "# barcode: $barcode\n";
$q->delete('barcode'); # empty form field

my $row;

$ENV{REQUEST_URI} =~ s{/intranet/}{/cgi-bin/koha/}; # fix plack rewrite

print $q->header( -charset => 'utf-8' ), qq{
<!DOCTYPE html>
<html>
  <head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <style>
	body {
		font-size: 200%;
	}
  </style>
  <title>Inventura</title>
</head>
  <body>
};

# Authentication
my ($status, $cookie, $sessionId) = C4::Auth::check_api_auth($q, { tools => 'inventory' });
if ($status ne "ok") {
	print "This requres tools - inventory permission";
	goto end_body;
}


print
      $q->start_form( -autocomplete => 'off' )
    , $q->textfield( -name => 'barcode', -autofocus => 'autofocus' )
    , $q->submit( -value => 'Search' )
#    , $q->checkbox( -name => 'izdatnice', -label => 'izdatnice' )
#    , $q->checkbox( -name => 'proizvodi', -label => 'prozivodi', -checked => 1 )
    , $q->end_form
    , qq|
<!--
<script type="text/javascript">
document.getElementsByName('barcode')[0].focus();
</script>
-->
	|
;

if ( $barcode ) {

	my $dbh = C4::Context->dbh;

	my $sql = qq{
	select
		itemnumber,
		items.biblionumber as biblionumber,
		title,
		author
	from items
	join biblio on items.biblionumber = biblio.biblionumber
	where barcode = ?
	};

	#warn "# sql $sql\n";

	my $sth = $dbh->prepare( $sql );
	$sth->execute( $barcode );
	if ( $sth->rows ) {

			$row = $sth->fetchrow_hashref;

			print qq|
BARCODE: <tt>$barcode</tt><br>
TITLE: <b>$row->{title}</b><br>
AUTHOR: $row->{author}<br>
			|;

			my $sth_update = $dbh->prepare(qq{
			update items set datelastseen = now() where barcode = ?
			});
			$sth_update->execute( $barcode );

			my $sth_inventura = $dbh->prepare(qq{
			insert ignore into ffzg_inventura (date_scanned,barcode,source_id) values (date(now()), ?, ?)
			});
			$sth_inventura->execute( $barcode, C4::Context->userenv->{'id'} );

			my $sth_issues = $dbh->prepare(qq{
			select firstname,surname,userid,email from issues join borrowers on issues.borrowernumber = borrowers.borrowernumber where itemnumber = ?
			});

			$sth_issues->execute( $row->{'itemnumber'} );
			while ( my $row = $sth_issues->fetchrow_hashref ) {
				warn "# issues row ",dump($row);
				print "issued to ", $row->{firstname}, ' ', $row->{surname}, " returning...";
				AddReturn( $barcode, 'FFZG' );
			}
	} else {
			warn "ERROR: can't find $barcode\n";
	}

}

end_body:

print qq{
</body>
</html>
};
