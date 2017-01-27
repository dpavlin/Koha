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
my ( $redirect, $reader_ip_port ) = ( $1 . $3 , $2 ) if $url =~ s{(^.+)/ffzg/rfid/reader/([^/]+)/(.+)$}{$1};

warn "## $cookie $session $url";

open(my $fh, '>', "/dev/shm/rfid.$session");
print $fh $reader_ip_port;
close($fh);

output_html_with_http_headers $query, $cookie, join('',qq{
<html>
<a id="redirect" href="$redirect"">$redirect</a>
<pre>
$reader_ip_port },( IO::Socket::INET->new($reader_ip_port) && 'OK' || die "RFID ERROR $reader_ip_port : $!" ), qq{
</pre>
<script>
var e = document.getElementById('redirect');
console.log(e);
//e.click();
</script>
</html>
});
