#!/usr/bin/perl

use warnings;
use strict;

my $BASE_DIR;
BEGIN {

	$ENV{'KOHA_CONF'} = "/etc/koha/sites/$ENV{SITE}/koha-conf.xml";
	$BASE_DIR = '/srv/koha_ffzg';

} # BEGIN

use CGI qw( -utf8 );
{
    my $old_new = \&CGI::new;
    *CGI::new = sub {
        warn "# override CGI->new\n";
        my $q = $old_new->( @_ );
		if ( ! $CGI::PARAM_UTF8 ) {
			warn "# CGI->new -utf8 = ",$CGI::PARAM_UTF8;
			$CGI::PARAM_UTF8 = 1;
		}
		C4::Context->clear_syspref_cache();
		return $q;
    };
}


use Plack::Builder;
use Plack::App::CGIBin;
use Plack::App::Directory;


use lib $BASE_DIR;
use lib "$BASE_DIR/installer";
use lib "/srv/koha_ffzg/misc/plack/lib";

use C4::Context;
use C4::Languages;
use C4::Members;
use C4::Boolean;
use C4::Letters;
use C4::Koha;
use C4::XSLT;
use C4::Branch;
use C4::Category;
=for preload
use C4::Tags; # FIXME
=cut

C4::Context->disable_syspref_cache();

warn "# $0 BASE_DIR=$BASE_DIR";

my $app=Plack::App::CGIBin->new(root => "$BASE_DIR");

use Data::Dumper;

builder {

	enable sub {
		my ( $app, $env ) = @_;
		return sub {
			my $env = shift;
			C4::Context->clear_syspref_cache();
			warn Dumper( $env );
			$app->( $env );
		}
	};

#	enable 'StackTrace';
	enable 'ReverseProxy';

	mount "/cgi-bin/koha" => $app;

};
