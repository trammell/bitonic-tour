use strict;
use warnings;
use Algorithm::TravelingSalesman::BitonicTour;
use Test::More 'no_plan';
use Test::Exception;

use_ok('Algorithm::TravelingSalesman::BitonicTour');
my $b = Algorithm::TravelingSalesman::BitonicTour->new;
is($b->n_points, 0);

$b->add_point(0,0);
is($b->n_points, 1);
is_deeply( [$b->sorted_points], [[0,0]] );

$b->add_point(3,0);
is($b->n_points, 2);
is_deeply( [$b->sorted_points], [[0,0], [3,0]] );

$b->add_point(2,1);
is($b->n_points, 3);
is_deeply( [$b->sorted_points], [[0,0], [2,1], [3,0]] );

$b->add_point(1,1);
is($b->n_points, 4);
is_deeply( [$b->sorted_points], [[0,0], [1,1], [2,1], [3,0]] );

# try to add a bogus point

{
    dies_ok { $b->add_point(2,1) } 'repeated X-coordinate should die';
    dies_ok { $b->add_point(2,2) } 'repeated X-coordinate should die';
    dies_ok { $b->add_point(2,3) } 'repeated X-coordinate should die';
    throws_ok { $b->add_point(2,1) } qr/duplicates previous point/,
        'with a nice error message';
}


is_deeply( [$b->coord(0)], [ 0,0 ] );
is_deeply( [$b->coord(-1)], [ 3,0 ] );

# check mah deltas
{
    my $d = sub { return 0 + sprintf('%.3f', $b->delta(@_)) };
    is( $d->(0,0), 0.0);
    is( $d->(1,1), 0.0);
    is( $d->(0,1), 1.414);
    is( $d->(0,2), 2.236);
    is( $d->(0,3), 3.0);
}
