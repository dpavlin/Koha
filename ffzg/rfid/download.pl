#!/usr/bin/perl

use strict;
use warnings;

use CGI;
use JSON;
use FindBin;
use IO::Socket::INET;
use Modern::Perl;

my $query = new CGI;

use Data::Dump qw(dump);
my $v = $query->Vars();
warn "# v ", dump( $v );

my $download = $query->param('download');
my $remote_host = $query->remote_host;
my $server_name = $query->server_name;

sub get_port {
		my $write = shift;
		my $exists = 0;
		my $path = "download/$remote_host";
		my $port = 0;
		if ( -e $path ) {
			open(my $fh, '<', $path);
			$port = <$fh>;
			$exists = 1;
		} else {

			my @nr = glob('reader/*:*');
			my $nr = scalar @nr;
			warn "# nr = $nr\n";
			$port = 9100 + $nr;

			if ( $write ) {
				open(my $fh, '>', $path);
				print $fh $port;
				close($fh);
			}
		}
	return ( $port, $port - 100, $exists );
}

my ( $serial_port, $json_port, $exists ) = get_port;
my $koha_url = "https://ffzg.koha-dev.rot13.org:8443/cgi-bin/koha/ffzg/rfid/reader/$server_name:$json_port/mainpage.pl";
my $title = $remote_host . ' '. ( $exists ? 'REINSTALL' : 'INSTALL' );

if ( ! $download ) {
	print $query->header, qq{<html><head><title>$title</title></head><body><h1>$title</h1>};
}

if ( $remote_host !~ m/^10\.60\./ ) {
	print qq{http://rfid.koha-dev.vbz.ffzg.hr/register.pl not on intranet but on };
	die $remote_host;
} elsif ( $download ) {
	print qq{Content-type: applicaton/binary\r\ncontent-disposition: attachment; filename="$download"\r\n\r\n};
	if ( $download eq 'com2tcp.exe' ) {
		open(my $fh, '<', '/srv/Biblio-RFID/com2tcp-1.3.0.0-386/com2tcp.exe');
		binmode $fh;
		binmode STDOUT;
		local $/ = undef;
		print <$fh>;
		close($fh);
		exit 0;
	} elsif ( $download eq 'rfid.bat' ) {
		( $serial_port, $json_port, $exists ) = get_port( 1 ) if ! $exists; # write port once configuration is downloaded
		my $bat = qq{:loop\r\ncom2tcp.exe --ignore-dsr --baud 19200 \\\\.\\com2 $server_name $serial_port\r\ngoto loop\r\n};
		print $bat;
		warn "BAT: ",dump($bat);
		exit 0;
	} else {
		die "unknown download $download";
	}

} else {
#} elsif ( ! $exists ) {


	print qq{

<h2>Create rfid directory</h2>
<h2>Download files to the rfid directory</h2>
<ol>
<li><a href="?download=com2tcp.exe">com2tcp.exe</a> serial port redirector</li>
<li><a href="?download=rfid.bat">rfid.bat</a> script to start it</li>
</ol>
<h2>Create shortcut to rfid.bat on desktop<h2>
<h2>Run shortcut rfid.bat</h2>

	};

#} elsif ( $exists ) {
	print qq{<b>Using exists port $serial_port on $server_name for configuration</b>};

	if ( IO::Socket::INET->new("$server_name:$json_port") ) {
		print qq{

<h2>Chceck if readedr works and create shortcut on computer to it</h2>
<a href="$koha_url" target="koha">$koha_url</a>

		};
	} else {
		print qq{<form><input type=submit name="reload" value="Check connection to RFID reader"></form>};
	}

}
