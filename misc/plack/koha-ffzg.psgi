#!/usr/bin/perl

use warnings;
use strict;

my $BASE_DIR;
BEGIN {

	$ENV{'KOHA_CONF'} = "/etc/koha/sites/$ENV{SITE}/koha-conf.xml";
	$BASE_DIR = '/srv/koha_ffzg';

} # BEGIN

use lib("$BASE_DIR");
use lib("$BASE_DIR/installer");

use Plack::Builder;
use Plack::App::CGIBin;
use Plack::App::Directory;
use Plack::App::URLMap;
use Plack::Request;

use Mojo::Server::PSGI;

# Pre-load libraries
use C4::Boolean;
use C4::Koha;
use C4::Languages;
use C4::Letters;
use C4::Members;
use C4::XSLT;
use Koha::Caches;
use Koha::Cache::Memory::Lite;
use Koha::Database;
use Koha::DateUtils;

use CGI qw( -utf8 );
{
    no warnings 'redefine';
    my $old_new = \&CGI::new;
    *CGI::new = sub {
        my $q = $old_new->( @_ );
        $CGI::PARAM_UTF8 = 1;
        Koha::Caches->flush_L1_caches();
        Koha::Cache::Memory::Lite->flush();
		return $q;
    };
}

my $intranet = Plack::App::CGIBin->new(
    root => "$BASE_DIR"
)->to_app;

my $opac = Plack::App::CGIBin->new(
    root => "$BASE_DIR/opac"
)->to_app;

my $apiv1  = builder {
    my $server = Mojo::Server::PSGI->new;
    $server->load_app("$BASE_DIR/api/v1/app.pl");
    $server->to_psgi_app;
};

builder {
    enable "ReverseProxy";
    enable "Plack::Middleware::Static";
    # + is required so Plack doesn't try to prefix Plack::Middleware::
    enable "+Koha::Middleware::SetEnv";

    mount '/opac'          => $opac;
    mount '/intranet'      => $intranet;
    mount '/api/v1/app.pl' => $apiv1;

};
