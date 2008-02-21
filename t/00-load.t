#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Cormen::Bitonic' );
}

diag( "Testing Cormen::Bitonic $Cormen::Bitonic::VERSION, Perl $], $^X" );
