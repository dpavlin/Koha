package Plack::Middleware::Debug::Persistant;
use Modern::Perl;
use Plack::Util::Accessor qw(for);
use parent 'Plack::Middleware::Debug::Base';

use Data::Dump qw(dump);

sub run {
	my ( $self, $env, $panel ) = @_;
	sub {
		my $res = shift;
		my $stats = $Koha::Persistant::stats;
		my ( $hit, $miss ) = ( 0, 0 );
		$panel->content( $self->render_list_pairs( [
			map {
				$hit  += $stats->{$_}->[0];
				$miss += $stats->{$_}->[1];
				$_ => join('/', @{ $stats->{$_} })
			} keys %$stats
		] ) );
	        $panel->nav_subtitle(sprintf("%d/%d %.2f%%",$hit,$miss,$hit * 100/($hit+$miss || 1)));
	}
}

1;
