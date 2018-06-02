#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright (C) 2018 Dobrica Pavlinusic <dpavlin@rot13.org>
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

=head1 NAME

recall_notices.pl - cron script to generate and send recall notices

=head1 SYNOPSIS

./recall_notices.pl [--send-notices]

or, in crontab:
0 3 * * * recall_notices.pl

=head1 DESCRIPTION

This script searches for reserves issued in last day.

It is B<NOT> related to Koha's recall feature which is under development
L<https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19532>

=head1 OPTIONS

=over

=item B<--send-notices>

Send FFZG_RECALL notices to patrons.

Note that this option does not support digest yet.

=back

=cut

use Modern::Perl;
use Pod::Usage;
use Getopt::Long;

use lib '/srv/koha_ffzg';

use C4::Circulation;
use C4::Context;
use C4::Log;
use C4::Letters;
use Koha::Checkouts;
use Koha::Libraries;
use Koha::Patrons;

use Data::Dump qw(dump);

my ( $help, $send_notices );
GetOptions(
    'h|help' => \$help,
    'send-notices' => \$send_notices,
) || pod2usage(1);

pod2usage(0) if $help;

cronlogaction();

my $dbh = C4::Context->dbh();
my $sth = $dbh->prepare( <<"END_SQL" );
select
	issues.borrowernumber,
	reserves.biblionumber,
	issues.itemnumber
from reserves
join items on reserves.biblionumber=items.biblionumber
join issues on issues.itemnumber=items.itemnumber
join borrowers on borrowers.borrowernumber=issues.borrowernumber
where (
		(
			(
					categorycode = 'N1' or
					categorycode = 'POC' or
					categorycode = 'KNJIZ' or
					categorycode = 'Z1' or
					categorycode = 'V1'
			) and
				datediff(reservedate,issuedate) > 30
		) or (
			categorycode like 'S%' and datediff(reservedate,issuedate) > 14
		)
) and reservedate > now() - interval 1 day
order by reserves.biblionumber ;
END_SQL

$sth->execute();

while ( my $row = $sth->fetchrow_hashref ) {
	warn "# row = ",dump($row),$/;

	if ( $send_notices ) {
        my $patron = Koha::Patrons->find($row->{borrowernumber});

        my $letter = C4::Letters::GetPreparedLetter(
            module      => 'circulation',
            letter_code => 'FFZG_RECALL',
            tables      => {
                borrowers => $row->{borrowernumber},
                issues    => $row->{itemnumber},
                items     => $row->{itemnumber},
                biblio    => $row->{biblionumber},
            },
        );

        my $library = Koha::Libraries->find( $patron->branchcode );
        my $admin_email_address = $library->branchemail || C4::Context->preference('KohaAdminEmailAddress');

        C4::Letters::EnqueueLetter(
            {   letter                 => $letter,
                borrowernumber         => $row->{borrowernumber},
                message_transport_type => 'email',
                from_address           => $admin_email_address,
            }
        );
    }
}
