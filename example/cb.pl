#!perl

use strict;
use warnings;
use Algorithm::TravelingSalesman::BitonicTour;

my $b = Algorithm::TravelingSalesman::BitonicTour->new;
while (<>) {
    next if /^#/;
    next unless /\S/;
    $b->add_point(split ' ', $_);
}

print $b->solve;

