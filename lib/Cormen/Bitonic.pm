package Algorithm::TravelingSalesman::BitonicTour;

use strict;
use warnings FATAL => 'all';
use base 'Class::Accessor::Fast';
use Carp 'croak';
use List::Util 'reduce';
use Params::Validate qw/ validate_pos SCALAR /;
use Regexp::Common qw/ number /;

our $VERSION = '0.001';

Algorithm::TravelingSalesman::BitonicTour->mk_accessors(qw/ _coord _cost min_tour _points _sorted_points /);

=head1 NAME

Algorithm::TravelingSalesman::BitonicTour - solve the euclidean traveling-salesman problem with bitonic tours

=cut

=head1 SYNOPSIS

    use Algorithm::TravelingSalesman::BitonicTour;

    my $b = Algorithm::TravelingSalesman::BitonicTour->new;
    $b->add_point($x1,$y2);
    $b->add_point($x2,$y2);
    # ...add other points as needed...
    # get and print the solution
    my $solution = $b->solve;
    print $solution;

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

=head1 THE SOLUTION

=head2 Insight #1

B<The cost structure stores the cost of a tour>.

    c[i,j] = cost of a tour from point i => leftmost point => point j

=head2 Insight #2

B<>


    Why will they let us assume that no two x-coordinates are the same? What
    does the hint mean? What happens if I scan from left to right?

    If we scan from left to right, we get an open tour which uses all points to
    the left of our scan line.  

    In the optimal tour, the kth point is connected to exactly one point to the
    left of k (k != n).   Once I decide which point that is, say x. I need the optimal
    partial tour where the two endpoints are x and k-1, because if it isn't
    optimal I could come up with a better one.

    Hey, I have got a recurrence! And look, the two parameters which describe
    my optimal tour are the two endpoints.

    Let c[k,n] be the optimal cost partial tour where the two endpoints are k<n.

        c[k,n]   <= c[k,n-1] + d[n,n-1]   , when k < n-1
        c[n-1,n] <= c[k,n-1] + d[k,n]     , when k < n-1

    c[0,1] = d[0,1] 

    c[n-1, n] takes O(n) to update, c[k, n] k<n-1 takes O(1) to update. Total
    time is O(n^2).

    But this doesn't quite give the tour, but just an open tour. We simply must
    figure where the last edge to n must go. 

        Tour Cost = min[k=1..n]{ c[k,n] + d[k,n] }



===============

    A[i,j] = A[i,j-1] + d(j-1,j)                 if j >= i+2
    A[i,j] = min[ k < i ] { A[k,i] + d(k,j) }    if j  = i+1


=head1 METHODS

=head2 Algorithm::TravelingSalesman::BitonicTour->new()

Constructs a new C<Algorithm::TravelingSalesman::BitonicTour> solution object.

=cut

sub new {
    my $class = shift;
    my %new = (
        _cost   => {},
        _points => {},
    );
    my $self = bless \%new, $class;
    return $self;
}

=head2 $b->add_point($x,$y)

Adds a point to be included in the solution.  Method C<add_point()> checks to
make sure that no two points have the same I<x>-coordinate.  This method will
C<croak()> if anything goes wrong.

Example:

    $b->add_point(2,3);  # adds point (x=2, y=3) to the tour

=cut

sub add_point {
    my $self = shift;
    my $valid = { type => SCALAR, regexp => $RE{num}{real} };
    my ($x, $y) = validate_pos(@_, ($valid) x 2);
    if (exists $self->_points->{$x}) {
        my $py = $self->_points->{$x};
        croak "FAIL: point ($x,$y) duplicates previous point ($x,$py)";
    }
    else {
        $self->_points->{$x} = $y;
        $self->_sorted_points(undef);   # clear cache
        return [$x, $y];
    }
}

=head2 coord($n)

Returns an array containing the coordinates of point C<$n>.

Examples:

    my ($x0, $y0) = $b->coord(0);   # coordinates of leftmost point
    my ($x1, $y1) = $b->coord(1);   # coordinates of next point
    # ...
    my ($xn, $yn) = $b->coord(-1);  # coordinates of rightmost point

=cut

sub coord {
    my ($self, $n) = @_;
    return @{ ($self->sorted_points)[$n] };
}

=head2 $b->sorted_points()

Returns an array of points sorted by increasing I<x>-coordinate, i.e. the first
array element is the leftmost point.  Each point is represented as an arrayref
containing 2 elements.

The sorted array of points is cached, but the cache is cleared by each call to
add_point().

=cut

sub sorted_points {
    my $self = shift;
    unless ($self->_sorted_points) {
        my @x = sort { $a <=> $b } keys %{ $self->_points };
        my @p = map [ $_, $self->_points->{$_} ], @x;
        $self->_sorted_points(\@p);
    }
    return @{ $self->_sorted_points };
}

=head2 $b->n_points()

Returns the number of points currently stored in the solution object.

=cut

sub n_points {
    my $self = shift;
    return scalar keys %{ $self->_points };
}

=head2 $b->solve()

Solves the problem as configured.  See L</"THE SOLUTION"> above for algorithm
details.

Returns the length of the minimum tour.

=cut

sub solve {
    my $self = shift;
    if ($self->n_points < 1) {
        croak "FAIL: you need to add some points!";
    }
    elsif ($self->n_points == 1) {
        return 0;
    }
    else {
        $self->populate_costs;
        return $self->optimal_tour;
    }
}

=head2 $b->populate_costs

=cut

sub populate_costs {
    my $self = shift;
    my $R = $self->n_points - 1;    # mnemonic: index of Rightmost point

    # ugly hack: cost(0,1) is equal to delta(0,1); doing this makes later loop
    # indices
    $self->set_cost(0, 1, $self->delta(0,1) );

    # find optimal tours for all points 2, 3, ... up to R
    foreach my $k (2 .. $R) {

        # for each point "i" to the left of "k", calculate and save the optimal
        # tour cost from "i" to "k".
        foreach my $i (0 .. $k - 1) {
            my $cost = $self->optimal_cost($i,$k);
            $self->set_cost($i, $k, $cost);
        }
    }
}

=head2 $b->optimal_tour

Find the optimal complete tour by finding the minimum value of

=over 4

cost(i,N) + delta(i,N)

=back

=cut

sub optimal_tour {
    my $self = shift;
    unless (defined $self->min_tour) {
        my $R = $self->n_points - 1;    # mnemonic: index of Rightmost point
        my @tours = map {
            $self->cost($_,$R) + $self->delta($_,$R);
        } 0 .. $R - 1;
        my $tour = reduce { $a < $b ? $a : $b } @tours;
        $self->min_tour($tour);
    }
    return $self->min_tour;
}

=head2 $b->optimal_cost($i,$j)

Two cases, ($i < $j - 1) and ($i = $j - 1)

    A[i,j] = A[i,j-1] + d(j-1,j)                 if j > i+1
    A[i,j] = min[ k < i ] { A[k,i] + d(k,j) }    if j = i+1

Example:

    # determine the cost of 
    my $cost = $b->optimal_cost(20,25);

=cut

sub optimal_cost {
    my ($self, $i, $j) = @_;

    # assert that $i <= $j
    unless ($i <= $j) {
        local $" = q(,);
        croak "bad call: optimal_cost(@_)";
    }

    # the cost to go from a point to itself is zero
    if ($i == $j) {
        local $" = q(,);
        return 0;
    }

    # if $i and $j are adjacent, many valid bitonic tours (i => x => j) are
    # possible; choose the shortest one.
    if ($i + 1 == $j) {
        my @costs = map {
            my $x = $_;
            my $cost = $self->cost($x,$i) + $self->delta($x,$j);
            $cost;
        } 0 .. $i - 1;
        my $min_cost = reduce { $a < $b ? $a : $b } @costs;
        return $min_cost;
    }

    # if $i and $j are not adjacent, then only one bitonic tour (i => j-1 => j)
    # is possible.   FIXME: needs pointer to documentation
    if ($i + 1 < $j) {
        return $self->cost($i, $j - 1)+ $self->delta($j - 1,$j);
    }

    local $" = q(,);
    croak "bad call to optimal_cost(@_)";
}


=head2 $b->cost($i,$j)

Returns the cost associated with the bitonic tour from point C<$i> to C<$j>.

=cut

sub cost {
    my ($self, $i, $j) = @_;
    unless (exists $self->_cost->{$i}{$j}) {
        croak "Don't know the value of cost($i,$j)";
    }
    return $self->_cost->{$i}{$j};
}

=head2 $b->set_cost($k, $n, $cost)

Sets the cost associated with the tour with endpoints C<$k> and C<$n>.

=cut

sub set_cost {
    my ($self, $i, $j, $cost) = @_;
    $self->_cost->{$i}{$j} = $self->_cost->{$j}{$i} = $cost;
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
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Algorithm-TravelingSalesman-BitonicTour>.  I will be
notified, and then you'll automatically be notified of progress on your bug as
I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Algorithm::TravelingSalesman::BitonicTour

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Algorithm-TravelingSalesman-BitonicTour>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Algorithm-TravelingSalesman-BitonicTour>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Algorithm-TravelingSalesman-BitonicTour>

=item * Search CPAN

L<http://search.cpan.org/dist/Algorithm-TravelingSalesman-BitonicTour>

=back

=head1 COPYRIGHT & LICENSE

Copyright 2008 John Trammell, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;

