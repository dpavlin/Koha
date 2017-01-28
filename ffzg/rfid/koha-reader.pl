#!/usr/bin/perl

use Modern::Perl;
use CGI qw ( -utf8 );
use lib '/srv/koha_ffzg';
use C4::Auth;
use C4::Output;
use Data::Dump qw(dump);

my $query = new CGI;

# fake koha login so we can get valid session
my ( $template, $loggedinuser, $cookie, $flags ) = get_template_and_user(
    {
        template_name   => "intranet-main.tt",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { catalogue => 1, },
    }
);

my $session = $query->cookie('CGISESSID');
my $url = $query->url;
# hungle URL to get Koha authorization and keep our reader identification in URL
# https://ffzg.koha-dev.rot13.org:8443/cgi-bin/koha/ffzg/rfid/reader/10.60.0.92:9000/mainpage.pl
my ( $redirect, $reader_ip_port ) = ( $1 . $3 , $2 ) if $url =~ s{(^.+)/ffzg/rfid/reader/([^/]+)(/.+)$}{$1};

warn "## $session $reader_ip_port";

my $session_file = "/dev/shm/rfid.$session";
open(my $fh, '>', $session_file) || die "$session_file: $!";
print $fh $reader_ip_port;
close($fh);

sub check_rfid_reader {
	my $host_port = shift;
	if ( my $sock = IO::Socket::INET->new($reader_ip_port) ) {
		print $sock "GET /scan HTTP/1.0\r\n\r\n";
		local $/ = undef;
		return "OK\n\n" . <$sock>;
	} else {
		return "RFID ERROR $reader_ip_port : $!";
	}

}

output_html_with_http_headers $query, $cookie, join('',qq{
<html>
<a id="redirect" href="$redirect"">$redirect</a>
<ol>
<li>Koha session: <pre>$session },(-e $session_file ? 'OK' : 'ERROR: MISSING'),qq{</pre></li>
<li>RFID reader: <pre>$reader_ip_port }, check_rfid_reader( $reader_ip_port ), qq{</pre></li>
</ol>
<script>
var e = document.getElementById('redirect');
console.log(e);
//e.click();
</script>
</html>
});
