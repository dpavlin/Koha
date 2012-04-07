package Koha::Template::Plugin::Combine;
use Template::Plugin;
use base qw( Template::Plugin );
use warnings;
use strict;

# PLACK_DEBUG=1 always re-create files but report correct hit/miss ration

use File::Slurp;
use Digest::MD5;
use Data::Dump qw(dump);

sub new {
	my ($class, $context, @params) = @_;
	bless {
		_CONTEXT => $context,
		js  => [], # same as extension!
		css => [],
		inline => 1,
	}, $class;
}

sub _html_params {
	my $params = shift;
	return join(' ', map { $_ . '="' . $params->{$_} . '"' } keys %$params );
}

sub javascript {
	my ( $self, $params ) = @_;
	warn "## combine.javascript ", dump( $params );
	$params->{type} ||= 'text/javascript';
	push @{ $self->{js} }, $params;
	my $html = _html_params( $params );
	if ( $self->{inline} ) {
		return "<!-- script $html -->\n";
	} else {
		return "<script $html></script>\n";
	}
}

sub css {
	my ( $self, $params ) = @_;
	warn "## combine.css ",dump( $params );
	$params->{rel}  ||= 'stylesheet';
	$params->{type} ||= 'text/css';
	die "no href in ",dump($params) unless exists $params->{href};
	my $html = _html_params( $params );

	if ( exists $params->{media} ) { # FIXME not combined!
		push @{ $self->{css_media} }, "<link $html />";
		return "<!-- media $html -->";
	}

	push @{ $self->{css} }, $params;
	if ( $self->{inline}) {
		return "<!-- link $html -->\n";
	} else {
		return "<link $html />\n";
	}
}

sub combined_files {
	my ( $self, $what, $attr ) = @_;
	my $key = join(' ', map { $_->{$attr} } @{ $self->{$what} } );
	$key = Digest::MD5::md5_hex( $key ); # shorten filenames
	warn "# $what $attr key = $key\n";
	my $htdocs = C4::Context->config('intrahtdocs');
	$htdocs =~ s{/intranet-tmpl/?}{/}; # FIXME DocumentRoot even for OPAC
	my $path = "$htdocs/intranet-tmpl/combined/$key.$what";
	my $url  = "/intranet-tmpl/combined/$key.$what";
	$path =~ s{//+}{/}; # plack is picky about paths
	if ( -e $path ) {
		$Koha::Persistant::stats->{combine_files}->[0]++; # hit
		return $url if ! $ENV{PLACK_DEBUG}; # FIXME no caching with debug
	}
	$Koha::Persistant::stats->{combine_files}->[1]++ if ! $ENV{PLACK_DEBUG}; # miss

	my $mix;
	foreach my $path ( map { $_->{$attr} } @{ $self->{$what} } ) {
		warn "combine_files $what $attr - $path";
		my $chunk = read_file("$htdocs/$path");
		die "$htdocs/$path found \@import" if $what eq 'css' && $chunk =~ m'@import';
		$mix .= "\n/* BEGIN $path */\n$chunk\n/* END $path */\n";
	}
	my $combined_size = length($mix);
	write_file $path, $mix;
	warn "## $path ", -s $path, "/$combined_size bytes\n";
	return $url;
}

sub html {
	my ( $self, $params ) = @_;

	if ( $self->{inline} ) {
		warn "## css ",dump( $self->{css} );
		warn "## javascript ",dump( $self->{js} );
		my $mix;
		my $js  = $self->combined_files( 'js'  => 'src' );
		my $css = $self->combined_files( 'css' => 'href' );
		return qq{
		<!-- combined.html -->
		<link type="text/css" href="$css" rel="stylesheet" />
		<script type="text/javascript" src="$js"></script>
		};
	} else {
		return "<!-- javascript and css combine disabled -->";
	}
}

1;
