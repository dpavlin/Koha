#!/usr/bin/perl
use Plack::Builder;
use Plack::App::CGIBin;
use lib qw( ./p5-plack-devel-debug-devel-size/lib ./lib );
use Plack::Middleware::Debug;
use Plack::App::Directory;

use C4::Context;
use C4::Languages;
use C4::Members;
use C4::Dates;
use C4::Boolean;
use C4::Letters;
use C4::Koha;
use C4::XSLT;
use C4::Branch;
use C4::Category;

use Devel::Size 0.77; # 0.71 doesn't work for Koha
my $watch_size = [
	map { s/^.*C4/C4/; s/\//::/g; s/\.pm$//; $_ } # fix paths
	grep { /C4/ }
	keys %INC
];
	

my $app=Plack::App::CGIBin->new(root => $ENV{INTRANETDIR} || $ENV{OPACDIR});

builder {

	enable_if { $ENV{PLACK_DEBUG} } 'Debug',  panels => [
 		qw(Koha Persistant),
		qw(Environment Response Timer Memory),
		[ 'Profiler::NYTProf', exclude => [qw(.*\.css .*\.png .*\.ico .*\.js .*\.gif)] ],
#		[ 'DBITrace', level => 1 ], # a LOT of fine-graded SQL trace
		[ 'DBIProfile', profile => 2 ],
#		[ 'Devel::Size', for => $watch_size ],
	];

	enable_if { $ENV{PLACK_DEBUG} } 'StackTrace';

	enable_if { $ENV{INTRANETDIR} } "Plack::Middleware::Static",
		path => qr{^/intranet-tmpl/}, root => '/srv/koha/koha-tmpl/';

	enable_if { $ENV{OPACDIR} } "Plack::Middleware::Static",
		path => qr{^/opac-tmpl/}, root => '/srv/koha/koha-tmpl/';

	enable_if { $ENV{PLACK_MINIFIER} } "Plack::Middleware::Static::Minifier",
		path => qr{^/(intranet|opac)-tmpl/},
		root => './koha-tmpl/';


	mount "/cgi-bin/koha" => $app;

};

