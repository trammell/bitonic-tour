use strict;
use warnings;
use Cormen::Bitonic;
use Test::More 'no_plan';

use_ok('Cormen::Bitonic');
my $b = Cormen::Bitonic->new;
$b->add_point(0,0);
is_deeply( [$b->points], [[0,0]] );

$b->add_point(3,0);
is_deeply( [$b->points], [[0,0], [3,0]] );

$b->add_point(2,1);
is_deeply( [$b->points], [[0,0], [2,1], [3,0]] );

$b->add_point(1,1);
is_deeply( [$b->points], [[0,0], [1,1], [2,1], [3,0]] );

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
