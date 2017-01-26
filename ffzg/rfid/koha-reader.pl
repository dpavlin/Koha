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
my $url = $query->self_url;
my ( $redirect, $reader_ip_port ) = ( $1 . '/mainpage.pl', $2 ) if $url =~ s{(^.+)/ffzg/rfid/reader/([^/]+)/.+$}{$1};

warn "## $cookie $session $url";

open(my $fh, '>', "/dev/shm/rfid.$session");
print $fh $reader_ip_port;
close($fh);

output_html_with_http_headers $query, $cookie, qq{
<html>
<a id="redirect" href="$redirect"">$redirect</a>
<pre>
$reader_ip_port
</pre>
<script>
var e = document.getElementById('redirect');
console.log(e);
e.click();
</script>
</html>
};
