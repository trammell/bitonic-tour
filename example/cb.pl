#!perl

use strict;
use warnings;
use Algorithm::TravelingSalesman::BitonicTour;

my $b = Algorithm::TravelingSalesman::BitonicTour->new;

# Grid points from Cormen, Figure 15.9, p. 365.
# Note that the points don't need to be added in left-to-right order.

$b->add_point(0,6);
$b->add_point(5,4);
$b->add_point(7,5);
$b->add_point(8,2);
$b->add_point(6,1);
$b->add_point(1,0);
$b->add_point(2,3);

print $b->solve;

