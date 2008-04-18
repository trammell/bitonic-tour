use strict;
use warnings;
use Algorithm::TravelingSalesman::BitonicTour;
use Data::Dumper;
use Test::More 'no_plan';
use Test::Exception;

use_ok('Algorithm::TravelingSalesman::BitonicTour');

# solve a large problem (simple trapezoid)
{
    my $b = Algorithm::TravelingSalesman::BitonicTour->new;
    $b->add_point(@$_) for points();
    my ($length, @points) = $b->solve;
    is(sprintf('%.3f', $length), 6.282, 'known correct length');

    my $points = do {
        my @p = map "[@$_[0],@$_[1]]", @points[ 0 .. $#points - 1 ];
        join q( ), @p, @p;
    };

    my $correct_re = do {
        my @correct = map quotemeta, map { "[@$_[0],@$_[1]]" } points();
        my $pat = "@correct|@{[ reverse @correct ]}";
        qr/$pat/;
    };
    like($points, $correct_re);
    #diag "length=$length";
    #diag Dumper(@points);
    #like($points, qr/(0 2 4 6 8 10|10 8 6 4 2 0)/);
    #like($points, qr/(1 3 5 7 9|9 7 5 3 1)/);
    #diag "$length @points";
}

sub points {
    my $pi = 3.14159;
    my $N  = 99;    
    my $R  = 1;
    return map {
        my $theta = 2 * $pi * $_ / $N;
        my $x = $R * cos($theta);
        my $y = $R * sin($theta);
        [$x, $y];
    } 0 .. $N - 1;
}


