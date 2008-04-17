use strict;
use warnings;
use Data::Dumper;
use Test::More 'no_plan';
use Test::Exception;

local $Data::Dumper::Sortkeys = 1;
use_ok('Algorithm::TravelingSalesman::BitonicTour');

# set up a problem
my $b = Algorithm::TravelingSalesman::BitonicTour->new;
$b->add_point(0,0);
$b->add_point(1,1);
$b->add_point(2,1);
$b->add_point(3,0);
is($b->N, 4);
is_deeply( [$b->sorted_points], [[0,0], [1,1], [2,1], [3,0]] );

# populate optimal costs array
$b->populate_partial_tours;
#diag(Dumper($b));

# make sure invalid cost queries throw an exception
throws_ok { $b->cost(42,142) } qr/Don't know the cost of tour\(42,142\)/,
    'invalid cost dies';

# verify calculated costs
{
    my $c = sub { 0 + sprintf('%.2f', $b->cost(@_)) };
    is( $c->(0,1), 1.41 );  # 0 1
    is( $c->(0,2), 2.41 );  # 0 1 2
    is( $c->(0,3), 3.83 );  # 0 1 2 3
    is( $c->(1,2), 3.65 );  # 1 0 2
    is( $c->(1,3), 5.06 );  # 1 0 2 3
    is( $c->(2,3), 5.41 );  # 2 1 0 3 (not 2 0 1 3)
}

