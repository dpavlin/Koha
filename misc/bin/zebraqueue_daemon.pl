#!/usr/bin/perl -w

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

# Writen 02/03/2011 by Tomas Cohen Arazi (tomascohen@gmail.com)
#                      Universidad Nacional de Cordoba / Argentina

# Daemon to watch the zebraqueue table and update zebra indexes as needed

use strict;
BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/kohalib.pl" };
}
use POE;
use Time::HiRes qw(time);
use C4::Context;
use C4::Catalog::Zebra;


my $authUpdateRatio;
my $biblioUpdateRatio;
my $tickCounter;


sub handler_start
{
	my ( $kernel, $heap, $session ) = @_[ KERNEL, HEAP, SESSION ];
	my $time = localtime(time);

	print "$time Zebraqueue daemon started\n";

	# Initialize counter
	$tickCounter  = 0;

	# Get timer settings
	$authUpdateRatio	= (C4::Context->preference("ZebraAuthUpdateRatio")||10);
	$biblioUpdateRatio	= (C4::Context->preference("ZebraBiblioUpdateRatio")||6);

	# Log
	my $authPrefsString = (C4::Context->preference("ZebraAuthUpdateRatio") ? 'syspref' : 'default');
	print "$time Authorities update ratio (secs): $authUpdateRatio ($authPrefsString)\n";
	my $biblioUpdateSecs = $biblioUpdateRatio * $authUpdateRatio;
	my $biblioPrefsString = (C4::Context->preference("ZebraBiblioUpdateRatio") ? 'syspref' : 'default');
	print "$time Biblios update ratio (secs): $biblioUpdateSecs ($biblioPrefsString)\n";

	$kernel->delay(tick => $authUpdateRatio);
}


sub handler_stop
{
	my $heap = $_[HEAP];
	my $time = localtime(time);
	# Log
	print "$time Zebraqueue daemon stopped - POE Session ended\n";
	delete $heap->{session};
}


sub handler_tick
{
	my ( $kernel, $heap, $session ) = @_[ KERNEL, HEAP, SESSION ];
	my $ret = 0;
	$tickCounter  = $tickCounter + 1;


	# Calculate if we have to update biblios too
	# Check: biblioUpdateRatio ?= tickCounter
	if ($biblioUpdateRatio == $tickCounter) {
		# Update biblios and auths
		$ret = C4::Catalog::Zebra::UpdateAuthsAndBiblios();
		# Reset counter
		$tickCounter  = 0;
	} else {
		# Update only auths
		$ret = C4::Catalog::Zebra::UpdateAuths();
	}

	$kernel->delay(tick => $authUpdateRatio);
}

POE::Session->create(
	inline_states => {
		_start       => \&handler_start,
		tick         => \&handler_tick,
		_stop        => \&handler_stop,
	},
);

POE::Kernel->run();
exit 0;
