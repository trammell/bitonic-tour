#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Algorithm::TravelingSalesman::BitonicTour' );
}

diag( "Testing Algorithm::TravelingSalesman::BitonicTour $Algorithm::TravelingSalesman::BitonicTour::VERSION, Perl $], $^X" );
