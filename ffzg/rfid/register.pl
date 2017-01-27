#!/usr/bin/perl

use strict;
use warnings;

use CGI;
use JSON;
use FindBin;
use IO::Socket::INET;

my $query = new CGI;

use Data::Dump qw(dump);
my $v = $query->Vars;
warn "# v ", dump( $v );

my $hash = {
	remote_host => $query->remote_host,
};


if ( my $c = $query->cookie('rfid_reader') ) {
	warn "## RFID cookie rfid_reader = $c\n";
	$hash->{local_ip} = $c;
	$hash->{have_reader} = 1;
}

if ( my $session = $query->cookie("CGISESSID") ) {
	$hash->{session} = $session;
	my $path = "/dev/shm/rfid.$session";
	warn "## RFID session $path\n";
	if ( -e $path ) {
		open(my $fh, '<', $path);
		$hash->{local_ip} = <$fh>;
		$hash->{have_reader} = 1;
	}
}

my $dir = $FindBin::Bin;

if ( my $koha_login = $query->param('koha_login') ) {
	my $path = "$dir/user/$koha_login";
	$hash->{koha_login} = $koha_login;
	if ( -e $path ) {
		nopen(my $fh, '<', $path);
		$hash->{local_ip} = <$fh>;
		$hash->{have_reader} = 1;
		warn "RFID: $koha_login -> $hash->{local_ip}\n";
		close $fh;
	} else {
		#warn "# no $path";
	}

} elsif ( $query->param('_last') ) {

	my $v = $query->Vars;
	my $ip = $v->{HTTP_LISTEN};

	if ( ! $ip ) {
		die "RFID ERROR: no HTTP_LISTEN in ",dump($v);
	}

	my $path = "$dir/ip/$ip"; # FIXME
	open(my $fh, '>', $path);
	print $fh encode_json( $v );
	close($fh);
	warn "RFID $path $ip ", -s $path, "\n";

	# XXX this place is too early to test connection, since our client is not listening yet
	#my $sock = IO::Socket::INET->new($ip) || die "RFID $ip : $!"; # XXX

	$hash->{local_ip} = $ip;
	$hash->{have_reader} = 1;

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
					s/localhost:9000/$url/g;
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

} elsif ( my $ip = $query->param('register_reader') ) {
	my $url = $query->self_url;
	$url =~ s{/koha/ffzg/rfid.*$}{/koha/mainpage.pl};
	warn "## RFID register_rader $ip -> $url\n";
	print "Location: $url\r\n",
		"Cookie: rfid_reader=$ip\r\n",
		"\r\n";
} else {
	print "Content-type: application/json; charset=utf-8\r\n\r\n";
	print encode_json $hash;
}
warn "## RFID hash = ",dump($hash);
