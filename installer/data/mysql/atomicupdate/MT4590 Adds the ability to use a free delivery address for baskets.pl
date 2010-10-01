#! /usr/bin/perl
use strict;
use warnings;
use C4::Context;
my $dbh=C4::Context->dbh;if ( C4::Context->preference("Version") < TransformToNum($DBversion) ) {
    $dbh->do(
        qq{
	ALTER TABLE `aqbasketgroups` ADD `freedeliveryplace` TEXT NULL AFTER `deliveryplace`;
	}
    );

    print "Upgrade to $DBversion done (adding freedeliveryplace to basketgroups)\n";
    SetVersion($DBversion);
}

