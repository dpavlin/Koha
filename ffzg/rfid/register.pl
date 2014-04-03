#!/usr/bin/perl

use strict;
use warnings;

use CGI;
use JSON;
use FindBin;

my $query = new CGI;

my $hash = {
	remote_host => $query->remote_host,
};

my $dir = $FindBin::Bin;
my $path = "$dir/ip/" . $hash->{remote_host};

if ( my $ip = $query->param('local_ip') ) {

	$hash->{local_ip} = $ip;
	open(my $fh, '>', $path);
	print $fh $hash->{local_ip};
	close($fh);
	warn "# $path ", -s $path, "\n";

} elsif ( -e $path ) {
	open(my $fh, '<', $path);
	my $ip = <$fh>;
	$hash->{local_ip} = $ip;
	close($fh);
} else {
	warn $hash->{_error} = "ERROR: ", $hash->{remote_host}, " don't have RFID reader assigned";
}

if ( $query->param('intranet-js') ) {
	print "Content-type: application/javascript\r\n\r\n";
	open(my $js, '<', 'koha-rfid.js');
	while(<$js>) {
		s/localhost/$hash->{local_ip}/g;
		print;
	}
	close($js);
} else {
	print "Content-type: application/json; charset=utf-8\r\n\r\n";
	print encode_json $hash;
}
