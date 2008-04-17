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

# make sure invalid tour queries throw an exception
throws_ok { $b->tour_cost(42,142) } qr/ERROR/, 'die on invalid cost limits';
throws_ok { $b->tour_cost(0,1,-1) } qr/ERROR/, 'die on invalid cost';
throws_ok { $b->optimal_partial_tour(1,0) } qr/ERROR/, 'die on invalid tour limits';

{
    my @tour = $b->optimal_partial_tour(0,2);
    is (sprintf('%.3f',$tour[0]), 2.414);
}

# verify calculated costs and paths
{
    my @tests = (
        [ 0,1 => 1.41 => 0, 1 ],
        [ 0,2 => 2.41 => 0, 1, 2 ],
        [ 0,3 => 3.83 => 0, 1, 2, 3 ],
        [ 1,2 => 3.65 => 1, 0, 2 ],
        [ 1,3 => 5.06 => 1, 0, 2, 3 ],
        [ 2,3 => 5.41 => 2, 1, 0, 3 ],
    );

    my $c = sub { 0 + sprintf('%.2f', $b->tour_cost(@_)) };
    my $p = sub { [ $b->tour_points(@_) ] };

    foreach my $t (@tests) {
        my ($i, $j, $length, @points) = @$t;
        is( $c->($i,$j), $length);
        is_deeply( $p->($i, $j), \@points);
    }
}

