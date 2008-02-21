package Cormen::Bitonic;

use strict;
use warnings;
use base 'Class::Accessor::Fast';
use Carp 'croak';
use Params::Validate qw/ validate_pos SCALAR /;
use Regexp::Common qw/ number /;

our $VERSION = '0.001';

Cormen::Bitonic->mk_accessors(qw/ _coord cost _in _points /);

=head1 NAME

Cormen::Bitonic - solve the euclidean traveling-salesman problem with bitonic tours

=cut

=head1 SYNOPSIS

    use Cormen::Bitonic;

    my $b = Cormen::Bitonic->new;
    $b->add_point($x1,$y2);
    $b->add_point($x2,$y2);
    # ...add other points as needed...
    $b->solve;
    print $b->solution;

=head1 DESCRIPTION

From Cormen, Chapter 15, pages 364-365:

=over 4

The B<euclidean traveling-salesman problem> is the problem of determining the
shortest closed tour that connects a given set of I<n> points in the plane.
Figure 15.9(a) shows the solution to a 7-point problem.  The general problem is
NP-complete, and its solution is therefore believed to require more than
polynomial time (see Chapter 34).

J. L. Bentley has suggested that we simplify the problem by restricting our
attention to B<bitonic tours>, that is, tours that start at the leftmost point,
go strictly left to right to the rightmost point, and then go strictly right to
left back to the starting point.  Figure 15.9(b) shows the shortest bitonic
tour of the same 7 points.  In this case, a polynomial-time algorithm is
possible.

Describe an I<O>(n^2)-time algorithm for determining an optimal bitonic tour.
You may assume that no two points have the same I<x>-coordinate.  (I<Hint:>
Scan left to right, maintaining optimal possibilities for the two parts of the
tour.)

=back

The solution to this problem eluded me when I first saw it; I wanted to solve
it in my own idiom.

=head1 METHODS

=head2 new()

=cut

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    return $self;
}

=head2 $b->add_point($x,$y)

Adds a point to the internal data structure.  Checks inputs to make sure
I<x>-coordinates of input points are unique.

Example:

    $b->add_point(2,3);  # adds x,y coordinate point [2,3]

=cut

sub add_point {
    my $self = shift;
    my $n = { type => SCALAR, regexp => $RE{num}{real} };
    my ($x, $y) = validate_pos(@_, ($n) x 2);
    $self->_in({}) unless $self->_in;
    if (exists $self->_in->{$x}) {
        my $py = $self->_in->{$x};
        croak "FAIL: point ($x,$y) duplicates previous point ($x, $py)";
    }
    else {
        $self->_in->{$x} = $y;
        $self->_points([]);
        return [$x, $y];
    }
}

=head2 coord($n)

Returns an array containing the coordinates of point C<$n>.

Examples:

    my ($x0, $y0) = $b->coord(0); # coordinates of leftmost point
    my ($u, $v) = $b->coord(-1);  # coordinates of rightmost point

=cut

sub coord {
    my ($self, $n) = @_;
    return @{ ($self->points)[$n] };
}

=head2 $b->points()

Returns an array of points, sorted by their I<x>-coordinate.  Each point is
represented as an arrayref containing 2 elements.

The array value is cached, but the cache is cleared by each call to
add_point().

=cut

sub points {
    my $self = shift;
    unless (@{ $self->{_points} }) {
        my @x = sort { $a <=> $b } keys %{ $self->_in };
        my @p = map [ $_, $self->_in->{$_} ], @x;
        $self->{_points} = \@p;
    }
    return @{ $self->{_points} };
}

=head2 $b->solve()

Solves the problem as configured.

    Why will they let us assume that no two x-coordinates are the same? What
    does the hint mean? What happens if I scan from left to right?

    If we scan from left to right, we get an open tour which uses all points to
    the left of our scan line.  

    In the optimal tour, the kth point is connected to exactly one point to the
    left of k.   Once I decide which point that is, say x. I need the optimal
    partial tour where the two endpoints are x and k-1, because if it isn't
    optimal I could come up with a better one.

    Hey, I have got a recurrence! And look, the two parameters which describe
    my optimal tour are the two endpoints.

    Let c[k,n] be the optimal cost partial tour where the two endpoints are k<n.

    c[k,n] <= c[k,n-1] + d[n,n-1], when k < n-1
    c[n-1,n] <= c[k,n-1] + d[k,n], when k < n-1

    c[0,1] = d[0,1] 

    c[n-1, n] takes O(n) to update, c[k, n] k<n-1 takes O(1) to update. Total
    time is O(n^2).

    But this doesn't quite give the tour, but just an open tour. We simply must
    figure where the last edge to n must go. 

        Tour Cost = min[k=1..n]{ c[k,n] + d[k,n] }

=cut

sub solve {
    my $self = shift;
    my @points = $self->points;
    if (@points < 2) {
        warn "your salesman isn't much of a traveller...";
        return;
    }

    # initialize the cost structure with the first line segment
#   $self->cost(0,1, delta($points[0], $points[1]);

#   foreach my $n (2 .. $#points) {
#       foreach my $k (0 .. $n - 1) {
#           $self->cost($k, $n - 1)
#           + delta( $k, $n - 1);
#
#
#           $self->cost($i,$j);        
#       }
#   }
}

sub cost {
    my ($self, $i, $j) = @_;
    if (@_) {
        $self->_cost->{$i}{$j} = $self->_cost->{$j}{$i} = $_[0];
    }
    return $self->_cost->{$i}{$j};
}

=head2 $b->delta($n1,$n2);

Returns the distance from point C<$n1> to point C<$n2>.

Examples:

    # print the distance from the leftmost to the next point
    print $b->delta(0,1);
    # print the distance from the leftmost to the rightmost point
    print $b->delta(0,-1);

=cut

sub delta {
    my ($self, $n1, $n2) = @_;
    my ($x1, $y1) = $self->coord($n1);
    my ($x2, $y2) = $self->coord($n2);
    return sqrt(
        (($x1 - $x2) * ($x1 - $x2))
        + 
        (($y1 - $y2) * ($y1 - $y2))
    );
}


=head1 RESOURCES

=over 4

=item

Cormen, Thomas H.; Leiserson, Charles E.; Rivest, Ronald L.; Stein, Clifford
(2001). Introduction to Algorithms, second edition, MIT Press and McGraw-Hill.
ISBN 978-0-262-53196-2. 

=back

=head1 AUTHOR

John Trammell, C<< <johntrammell at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-cormen-bitonic at rt.cpan.org>,
or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Cormen-Bitonic>.  I will be
notified, and then you'll automatically be notified of progress on your bug as
I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Cormen::Bitonic

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Cormen-Bitonic>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Cormen-Bitonic>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Cormen-Bitonic>

=item * Search CPAN

L<http://search.cpan.org/dist/Cormen-Bitonic>

=back

=head1 COPYRIGHT & LICENSE

Copyright 2008 John Trammell, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;

