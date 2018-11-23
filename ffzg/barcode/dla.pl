#!/usr/bin/perl

# KOHA_CONF=/etc/koha/sites/ffzg/koha-conf.xml perl -I /srv/koha_ffzg dlna.pl scan=1

use Modern::Perl;

use C4::Context;
use Data::Dump qw(dump);
use CGI qw ( -utf8 );
use autodie;

my $q = new CGI;
my $dbh = C4::Context->dbh;

print
    $q->header( -charset => 'utf-8' ),
    , $q->start_html( -title => 'DLA RFID tag import from share' )
	;

while(<DATA>) {
	if ( m/^select/i ) {
		print qq{<table>\n};
		my $sth = $dbh->prepare($_);
		$sth->execute;
		while ( my $row = $sth->fetchrow_arrayref ) {
			print qq{<tr><td>}, join(qq{</td><td>}, @$row), qq{</td></tr>\n};
		}
		print qq{</table>\n};
	} else {
		print "$_<br>\n";
	}
}

if ( $q->param('scan') ) {

		print qq{<pre>};

		my $sth = $dbh->prepare(qq{
select date_scanned,source_id,count(*) from ffzg_inventura group by date_scanned,source_id order by date_scanned desc;
		});
		$sth->execute;

		my $sth_insert = $dbh->prepare(qq{
insert ignore into ffzg_inventura (date_scanned,source_id,barcode) values (?,?,?)
		});

		my @database;
		my $date_scanned_source_id;
		while ( my $row = $sth->fetchrow_arrayref ) {
			push @database, $row;
			$date_scanned_source_id->{ $row->[0] }->{ $row->[1] } = $row->[2];
		}


		open(my $find, '-|', qq{find /mnt/share/DLA/ . -name '*.pdX'});
		while(<$find>) {
			chomp;
			if ( m{/(\w+)/(\w+)/(20\d\d-\d\d-\d\d)/upload/inv/.*pdX$} ) {
				my ($path, $dir , $source_id, $date_scanned ) = ( $_, $1, $2, $3 );

				if ( my $count = $date_scanned_source_id->{ $date_scanned }->{ $source_id } ) {
					print "$date_scanned $source_id [$count] $path\n";
					next;
				}

				my $cache_path = "/tmp/dla.$date_scanned.$source_id";
				if ( -e $cache_path ) {
					print "$date_scanned $source_id NOT-IN-DATABASE $path $cache_path size ",-s $cache_path, "\n";
					next;
				}

				print "CONVERT $path -> $source_id $date_scanned $cache_path\n";
				open(my $cache, '>', $cache_path);

				open(my $string, '-|', qq{strings $path | sort -u});
				while(<$string>) {
					while ( s/^.*?(130\d{7})//g ) {
						my $barcode = $1;
						warn "## barcode: $barcode";
						$sth_insert->execute( $date_scanned, $source_id, $barcode );
						print "++ $date_scanned $source_id ++ $barcode ++\n";
						print $cache "$barcode\n";
					}
				}

				close($cache);
				print "# created $cache_path ", -s $cache_path, " bytes\n";

				last; # FIXME import just one on one page load
			}
		}
		print qq{</pre>};
}


__DATA__

-- total scanned by date ranges and source_id
select min(date_scanned),max(date_scanned),source_id,count(*) from ffzg_inventura group by source_id;

-- date scanned, source_id, tags seen
