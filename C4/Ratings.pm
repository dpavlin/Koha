package C4::Ratings;

# Copyright 2010 KohaAloha, NZ
#
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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
use warnings;
use Carp;
use Exporter;
use POSIX;

use C4::Debug;
use C4::Context;

#use Smart::Comments '####';

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

BEGIN {
    $VERSION = 3.00;
    @ISA     = qw(Exporter);

    @EXPORT = qw(
      &get_rating &add_rating &del_rating
    );

    #	%EXPORT_TAGS = ();
}

# ---------------------------------------------------------------------

sub get_rating {
    my ( $biblionumber, $borrowernumber ) = @_;

    my $query = "
	SELECT    count(rating_id) as total, sum(value) as sum  from ratings
    WHERE       biblionumber = ?";

    my $sth = C4::Context->dbh->prepare($query);
    $sth->execute($biblionumber);
    my $res = $sth->fetchrow_hashref();
####  $res
    my $q2 = "
	SELECT    value  from ratings
    WHERE       biblionumber = ? and borrowernumber = ?";

    my $sth1 = C4::Context->dbh->prepare($q2);

    #    $sth1->{TraceLevel} = 3;
    $sth1->execute( $biblionumber, $borrowernumber );
    my $res1 = $sth1->fetchrow_hashref();

    my ( $avg, $avgint ) = 0;
    eval {
        no warnings 'uninitialized';    #
        $avg = $res->{sum} / $res->{total};
    };
    $avgint = sprintf( "%.0f", $avg );

    my %rating_hash;
    $rating_hash{total}  = $res->{total};
    $rating_hash{avg}    = $avg;
    $rating_hash{avgint} = $avgint;
    $rating_hash{value}  = $res1->{"value"};
    #### %rating_hash
    return \%rating_hash;
}

sub add_rating {
    my ( $biblionumber, $borrowernumber, $value ) = @_;

    my $query = "delete from ratings where borrowernumber = ? and biblionumber = ?";
    my $sth   = C4::Context->dbh->prepare($query);
    $sth->execute( $borrowernumber, $biblionumber );

    $query = "INSERT INTO ratings (borrowernumber,biblionumber,value)
	VALUES (?,?,?)";
    $sth = C4::Context->dbh->prepare($query);
    $sth->execute( $borrowernumber, $biblionumber, $value );

    my $rating = get_rating( $biblionumber, $borrowernumber );

    return $rating;
}

sub del_rating {
    my ( $biblionumber, $borrowernumber ) = @_;

    my $dbh = C4::Context->dbh;

    #    my $rv = $dbh->do( qq|delete from ratings where borrowernumber = ? and biblionumber = ?|);

    my $query = "delete from ratings where borrowernumber = ? and biblionumber = ?";
    my $sth   = C4::Context->dbh->prepare($query);
    $sth = C4::Context->dbh->prepare($query);

    #    $sth->trace(3);
    my $rv = $sth->execute( $borrowernumber, $biblionumber );
    $rv = 0 if $rv != 1;
    return $rv;
}





1;
