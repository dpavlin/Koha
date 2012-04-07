package Koha::Template::Plugin::Combine;
use Template::Plugin;
use base qw( Template::Plugin );
use warnings;
use strict;

use Data::Dump qw(dump);

sub new {
	my ($class, $context, @params) = @_;
	bless {
		_CONTEXT => $context,
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
	return "<script " . _html_params( $params ) . "></script>\n";
}

sub css {
	my ( $self, $params ) = @_;
	$params->{rel}  ||= 'stylesheet';
	$params->{type} ||= 'text/css';
	die "no href in ",dump($params) unless exists $params->{href};
	warn "## combine.css ",dump( $params );
	return "<link " . _html_params( $params ) . " />\n";
}

1;
