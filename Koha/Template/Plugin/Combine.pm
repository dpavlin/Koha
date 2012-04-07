package Koha::Template::Plugin::Combine;
use Template::Plugin;
use base qw( Template::Plugin );
use warnings;
use strict;

# PLACK_DEBUG=1 always re-create files but report correct hit/miss ration

use File::Slurp;
use Digest::MD5;
use Data::Dump qw(dump);

use CSS::Minifier::XS;
use JavaScript::Minifier::XS;

sub new {
	my ($class, $context, @params) = @_;
#warn "## context ",dump( $context );
	bless {
		_CONTEXT => $context,
		js  => [], # same as extension!
		css => [],
		inline => 1,
		minify => 1,
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
	} elsif ( my $cdata = $params->{cdata} ) {
		return qq|<script type="text/javascript" language="javascript">\n//<![CDATA[\n$cdata\n//]]>\n</script>\n|;
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
	my ( $self, $what, $attr, $params ) = @_;
warn "## combined_files $what $attr ",dump($params);
	my $key = join(' ', map { $_->{$attr} || $_->{cdata} } @{ $self->{$what} } );
	$key = Digest::MD5::md5_hex( $key ); # shorten filenames
	warn "# $what $attr key = $key\n";
	my $htdocs = C4::Context->config('intrahtdocs');
	$htdocs =~ s{/intranet-tmpl/?$}{}; # FIXME DocumentRoot even for OPAC

	my ( $path, $url );
	if ( my $prefix = $params->{prefix} ) {
		$path = "$htdocs/$prefix/combined/$key.$what";
		$url  = "$prefix/combined/$key.$what";
	} else {
		$path = "$htdocs/intranet-tmpl/combined/$key.$what";
		$url  = "/intranet-tmpl/combined/$key.$what";
	}
	$path =~ s{//+}{/}; # plack is picky about paths
	if ( -e $path ) {
		$Koha::Persistant::stats->{combine_files}->[0]++; # hit
		return $url if ! $ENV{PLACK_DEBUG}; # FIXME no caching with debug
	}
	$Koha::Persistant::stats->{combine_files}->[1]++ if ! $ENV{PLACK_DEBUG}; # miss

	my $mix;
	foreach my $include ( @{ $self->{$what} } ) {
		if ( my $path = $include->{$attr} ) {
			warn "combine_files $what $attr - $path";
			my $chunk = read_file("$htdocs/$path");
			die "$htdocs/$path found \@import" if $what eq 'css' && $chunk =~ m'@import';
			$mix .= "\n/* BEGIN $path */\n$chunk\n/* END $path */\n";
		} elsif ( my $cdata = $include->{cdata} ) {
			warn "combine_files CDATA $cdata";
			$mix .= "\n/* BEGIN CDATA */\n$cdata\n/* END CDATA */\n";
		}
	}
	my $combined_size = length($mix);
	if ( $self->{minify} ) {
		if ( $what eq 'js' ) {
			$mix = JavaScript::Minifier::XS::minify( $mix );
		} elsif ( $what eq 'css' ) {
			$mix = CSS::Minifier::XS::minify( $mix );
		} else {
			die "can't minify $what";
		}
		my $size = length($mix);
		warn sprintf "minify %s %d -> %d %.2f%%\n", $what, $combined_size, $size, $size * 100 / $combined_size;
	}
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
		my $js  = $self->combined_files( 'js'  => 'src', $params );
		my $css = $self->combined_files( 'css' => 'href', $params );
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
