#!/usr/bin/perl

use strict;
use warnings;

use CGI;
use JSON;
use FindBin;

my $query = new CGI;

use Data::Dump qw(dump);
#warn "# query ", dump( $query );

my $hash = {
	remote_host => $query->remote_host,
};

my $dir = $FindBin::Bin;
my $path = "$dir/ip/" . $hash->{remote_host};


if ( my $koha_login = $query->param('koha_login') ) {
	my $path = "$dir/user/$koha_login";
	$hash->{koha_login} = $koha_login;
	if ( -e $path ) {
		open(my $fh, '<', $path);
		$hash->{local_ip} = <$fh>;
		$hash->{have_reader} = 1;
		warn "RFID: $koha_login -> $hash->{local_ip}\n";
		close $fh;
	} else {
		#warn "# no $path";
	}

} elsif ( my $ip = $query->param('local_ip') ) {

	$hash->{local_ip} = $ip;
	open(my $fh, '>', $path);
	print $fh $hash->{local_ip};
	close($fh);
	warn "RFID $path $ip ", -s $path, "\n";

} elsif ( -e $path ) {
	open(my $fh, '<', $path);
	my $ip = <$fh>;
	chomp $ip;
	$hash->{local_ip} = $ip;
	close($fh);

} else {
	warn $hash->{_error} = "ERROR: ", $hash->{remote_host}, " don't have RFID reader assigned";
}

sub js_console {
	warn "RFID: ",@_;
	return q|
//$(document).ready( function() {
	console.log('|, join('', @_), qq|);
//}
|;
}

if ( $query->param('intranet-js') ) {
	print "Content-type: application/javascript\r\n\r\n";

	if ( exists $hash->{have_reader} ) {
		if ( my $local_ip = $hash->{local_ip} ) {
				chomp $local_ip;
				my $url = "/rfid/to/$local_ip";
				open(my $js, '<', 'koha-rfid.js');
				while(<$js>) {
					s/local_ip/$local_ip/g;
					s/localhost/$url/g;
					s{///$url}{$url}g; # relative urls
					print;
				}
				close($js);
		} else {
			warn "## RFID no local_ip for ",dump($hash);
		}
	} else {
#		warn "## RFID doesn't have reader ",dump($hash);
	}
} else {
	print "Content-type: application/json; charset=utf-8\r\n\r\n";
	print encode_json $hash;
	warn "## RFID hash = ",dump($hash);
}
