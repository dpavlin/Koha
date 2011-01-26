#!/usr/bin/perl
#
use strict;
use warnings;

use Test::More tests => 10;
#use Smart::Comments '####';

BEGIN {

    use FindBin;

    #    use lib "$FindBin::Bin/../C4/Ratings";
    use C4::Ratings;

    use_ok('C4::Ratings');

    my $rating1 = add_rating( 1, 2, 4 );
    ok( defined $rating1, 'add_rating() add a rating' );

    my $rating2 = add_rating( 1, 3, 1 );
    ok( defined $rating1, 'add_rating() add another rating' );

    my $rating3 = get_rating( 1, 2 );
    ok( defined $rating2, 'get_rating() get 1st rating' );

    ok( $rating3->{'avg'} == '2.5', "get_rating() bib's rating average(float)" );
    ok( $rating3->{'avgint'} == 2,  "get_rating() bib's rating average(int)" );
    ok( $rating3->{'total'} == 2,   "get_rating() bib's total rating rows" );
    ok( $rating3->{'value'} == 4,   "get_rating() bib's rating value" );

    my $rv1 = del_rating( 1, 2 );
    my $rv2 = del_rating( 1, 3 );

    ok( $rv1, 'del_rating() delete 1st rating' );
    ok( $rv1, 'del_rating() delete 2nd rating' );
}

=c

mason@xen1:~/g/head/t/db_dependent$ perl ./Ratings.t 
1..10
ok 1 - use C4::Ratings;
ok 2 - add_rating() add a rating
ok 3 - add_rating() add another rating
ok 4 - get_rating() get 1st rating
ok 5 - get_rating() bib's rating average(float)
ok 6 - get_rating() bib's rating average(int)
ok 7 - get_rating() bib's total rating rows
ok 8 - get_rating() bib's rating value
ok 9 - del_rating() delete 1st rating
ok 10 - del_rating() delete 2nd rating

=cut
