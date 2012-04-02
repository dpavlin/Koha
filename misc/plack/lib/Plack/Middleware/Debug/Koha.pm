package Plack::Middleware::Debug::Koha;
use Modern::Perl;
use parent 'Plack::Middleware::Debug::Base';

use Data::Dump qw(dump);

sub run {
	my ( $self, $env, $panel ) = @_;
	sub {
		my @evals = qw(
			C4::Context::ismemcached
		);

		my $res = shift;
		$panel->content( $self->render_list_pairs( [
			map { $_ => eval "$_" } @evals
		] ) );
	        $panel->nav_subtitle("eval");
	}
}

1;
