use strict;
use warnings;
use Algorithm::TravelingSalesman::BitonicTour;
use Data::Dumper;
use Test::More 'no_plan';
use Test::Exception;

use_ok('Algorithm::TravelingSalesman::BitonicTour');

# make sure an attempt to solve a problem with no points dies
{
    my $b = Algorithm::TravelingSalesman::BitonicTour->new;
    throws_ok { $b->solve } qr/need to add some points/,
        'bad problem throws exception';
#   diag Dumper($b);
}

# make sure a problem with exactly one point works
{
    my $b = Algorithm::TravelingSalesman::BitonicTour->new;
    $b->add_point(0,0);
    my $solution;
    lives_ok { $solution = $b->solve };
    is($solution, 0) or diag(Dumper($b));
}


# # now solve a real problem
# my $b = Algorithm::TravelingSalesman::BitonicTour->new;
# $b->add_point(0,0);
# $b->add_point(1,1);
# $b->add_point(2,1);
# $b->add_point(3,0);
# $b->solve;
# 
