use strict;
use warnings;
use Algorithm::TravelingSalesman::BitonicTour;
use Data::Dumper;
use Test::More 'no_plan';
use Test::Exception;

use_ok('Algorithm::TravelingSalesman::BitonicTour');

# solve a real problem (simple trapezoid)
{
    my $b = Algorithm::TravelingSalesman::BitonicTour->new;
    $b->add_point(0,0);
    $b->add_point(1,1);
    $b->add_point(2,1);
    $b->add_point(3,0);
    my ($length, @points) = $b->solve;
    is(sprintf('%.3f', $length), 6.828, 'known correct length');
    my $points = do {
        my @p = @points[ 0 .. $#points - 1 ];
        "@p @p";
    };
    like($points, qr/(0 1 2 3 0|0 3 2 1 0)/);
    diag "$length @points";
}

