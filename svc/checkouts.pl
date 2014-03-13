#!/usr/bin/perl

# This software is placed under the gnu General Public License, v2 (http://www.gnu.org/licenses/gpl.html)

# Copyright 2014 ByWater Solutions
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
use warnings;

use CGI;
use JSON qw(to_json);

use C4::Auth qw(check_cookie_auth);
use C4::Biblio qw(GetMarcBiblio GetFrameworkCode GetRecordValue );
use C4::Circulation qw(GetIssuingCharges CanBookBeRenewed GetRenewCount);
use C4::Context;

use Koha::DateUtils;

my $input = new CGI;

my ( $auth_status, $sessionID ) =
  check_cookie_auth( $input->cookie('CGISESSID'),
    { circulate => 'circulate_remaining_permissions' } );

if ( $auth_status ne "ok" ) {
    exit 0;
}

my @sort_columns = qw/date_due title itype issuedate branchcode itemcallnumber/;

my @borrowernumber   = $input->param('borrowernumber');
my $offset           = $input->param('iDisplayStart');
my $results_per_page = $input->param('iDisplayLength') || -1;
my $sorting_column   = $sort_columns[ $input->param('iSortCol_0') ]
  || 'issuedate';
my $sorting_direction = $input->param('sSortDir_0') eq 'asc' ? 'asc' : 'desc';

$results_per_page = undef if ( $results_per_page == -1 );

binmode STDOUT, ":encoding(UTF-8)";
print $input->header( -type => 'text/plain', -charset => 'UTF-8' );

my @parameters;
my $sql = '
    SELECT
        issuedate,
        date_due,

        biblionumber,
        biblio.title,
        author,

        itemnumber,
        barcode,
        itemnotes,
        itemcallnumber,
        replacementprice,

        issues.branchcode,
        branchname,

        itype,
        itemtype,

        borrowernumber,
        surname,
        firstname,
        cardnumber
    FROM issues
        LEFT JOIN items USING ( itemnumber )
        LEFT JOIN biblio USING ( biblionumber )
        LEFT JOIN biblioitems USING ( biblionumber )
        LEFT JOIN borrowers USING ( borrowernumber )
        LEFT JOIN branches ON ( issues.branchcode = branches.branchcode )
    WHERE borrowernumber
';

if ( @borrowernumber == 1 ) {
    $sql .= '= ?';
}
else {
    $sql = ' IN (' . join( ',', ('?') x @borrowernumber ) . ') ';
}
push( @parameters, @borrowernumber );

$sql .= " ORDER BY $sorting_column $sorting_direction ";

my $dbh = C4::Context->dbh();
my $sth = $dbh->prepare($sql);
$sth->execute( @parameters );

my $item_level_itypes = C4::Context->preference('item-level_itypes');

my @checkouts;
while ( my $c = $sth->fetchrow_hashref() ) {
    my ($charge) = GetIssuingCharges( $c->{itemnumber}, $c->{borrowernumber} );

    my ( $can_renew, $can_renew_error ) =
      CanBookBeRenewed( $c->{borrowernumber}, $c->{itemnumber} );

    my ( $renewals_count, $renewals_allowed, $renewals_remaining ) =
      GetRenewCount( $c->{borrowernumber}, $c->{itemnumber} );
    push(
        @checkouts,
        {
            DT_RowId   => $c->{itemnumber} . '-' . $c->{borrowernumber},
            title      => $c->{title},
            author     => $c->{author},
            barcode    => $c->{barcode},
            itemtype   => $item_level_itypes ? $c->{itype} : $c->{itemtype},
            itemnotes  => $c->{itemnotes},
            branchcode => $c->{branchcode},
            branchname => $c->{branchname},
            itemcallnumber => $c->{itemcallnumber}   || q{},
            charge         => $charge,
            price          => $c->{replacementprice} || q{},
            can_renew      => $can_renew,
            can_renew_error    => $can_renew_error,
            itemnumber         => $c->{itemnumber},
            borrowernumber     => $c->{borrowernumber},
            biblionumber       => $c->{biblionumber},
            issuedate          => $c->{issuedate},
            date_due           => $c->{date_due},
            renewals_count     => $renewals_count,
            renewals_allowed   => $renewals_allowed,
            renewals_remaining => $renewals_remaining,
            issuedate_formatted =>
              output_pref( dt_from_string( $c->{issuedate} ) ),
            date_due_formatted =>
              output_pref_due( dt_from_string( $c->{date_due} ) ),
            subtitle => GetRecordValue(
                'subtitle',
                GetMarcBiblio( $c->{biblionumber} ),
                GetFrameworkCode( $c->{biblionumber} )
            ),
            borrower => {
                surname    => $c->{surname},
                firstname  => $c->{firstname},
                cardnumber => $c->{cardnumber},
            }
        }
    );
}

my $data;
$data->{'iTotalRecords'}        = scalar @checkouts;                 #FIXME
$data->{'iTotalDisplayRecords'} = scalar @checkouts;
$data->{'sEcho'}                = $input->param('sEcho') || undef;
$data->{'aaData'}               = \@checkouts;

print to_json($data);
