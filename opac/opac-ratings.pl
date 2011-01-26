#!/usr/bin/perl

# Copyright 2010 KohaAloha, NZ
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

=head1

TODO :: Description here

C4::Scrubber is used to remove all markup content from the sumitted text.

=cut

use strict;
use warnings;
use CGI;
use CGI::Cookie;    # need to check cookies before having CGI parse the POST request
use JSON;

use C4::Auth qw(:DEFAULT check_cookie_auth);
use C4::Context;
use C4::Debug;
use C4::Output 3.02 qw(:html :ajax pagination_bar);
use C4::Dates qw(format_date);
use C4::Ratings;

use Data::Dumper;

#use Smart::Comments '####';

my %ratings = ();
my %counts  = ();
my @errors  = ();

my $is_ajax = is_ajax();
####  $is_ajax

my $query = ($is_ajax) ? &ajax_auth_cgi( {} ) : CGI->new();
####  $query

my $biblionumber   = $query->param('biblionumber');
my $borrowernumber = $query->param('borrowernumber');
my $value;

foreach ( $query->param ) {
    if (/^rating(.*)/) {
        $value = $query->param($_);
        last;
    }
}

my ( $template, $loggedinuser, $cookie );

if ($is_ajax) {

    $loggedinuser = C4::Context->userenv->{'number'};
    my $rating = add_rating( $biblionumber, $borrowernumber, $value );
    my $js_reply = "{total: $rating->{'total'}, value: $rating->{'value'}}";
    #### $js_reply

    output_ajax_with_http_headers( $query, $js_reply );
    exit;
} else {
    ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {   template_name   => "opac-user.tmpl",
            query           => $query,
            type            => "opac",
            authnotrequired => 0,                  # auth required to add ratings
            debug           => 0,
        }
    );
}

my $results = [];

( scalar @errors ) and $template->param( ERRORS => \@errors );

output_html_with_http_headers $query, $cookie, $template->output;

sub ajax_auth_cgi ($) {                            # returns CGI object
    my $needed_flags = shift;
    my %cookies      = fetch CGI::Cookie;
    my $input        = CGI->new;
    my $sessid       = $cookies{'CGISESSID'}->value || $input->param('CGISESSID');
    my ( $auth_status, $auth_sessid ) = check_cookie_auth( $sessid, $needed_flags );
    $debug
      and print STDERR "($auth_status, $auth_sessid) = check_cookie_auth($sessid," . Dumper($needed_flags) . ")\n";
    if ( $auth_status ne "ok" ) {
        output_ajax_with_http_headers $input, "window.alert('Your CGI session cookie ($sessid) is not current.  " . "Please refresh the page and try again.');\n";
        exit 0;
    }
    $debug and print STDERR "AJAX request: " . Dumper($input), "\n(\$auth_status,\$auth_sessid) = ($auth_status,$auth_sessid)\n";
    return $input;
}

