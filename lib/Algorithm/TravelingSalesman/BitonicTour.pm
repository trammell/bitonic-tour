package Algorithm::TravelingSalesman::BitonicTour;

use strict;
use warnings FATAL => 'all';
use base 'Class::Accessor::Fast';
use Carp 'croak';
use List::Util 'reduce';
use Params::Validate qw/ validate_pos SCALAR /;
use Regexp::Common qw/ number /;

our $VERSION = '0.01';

__PACKAGE__->mk_accessors(qw/ _coord _points _sorted_points _tour /);

=head1 NAME

Algorithm::TravelingSalesman::BitonicTour - solve the euclidean traveling-salesman problem with bitonic tours

=head1 SYNOPSIS

    use Algorithm::TravelingSalesman::BitonicTour;

    my $b = Algorithm::TravelingSalesman::BitonicTour->new;
    $b->add_point($x1,$y2);
    $b->add_point($x2,$y2);
    # ...add other points as needed...
    # get and print the solution
    my $solution = $b->solve;
    print $solution->distance;
    print join q( => ), $solution->points;

=head1 THE PROBLEM

From I<Introduction to Algorithms>, 2nd ed., T. H. Cormen, C. E. Leiserson, R.
Rivest, and C. Stein, MIT Press, 2001, problem 15-1, p. 364:

=over 4

The B<euclidean traveling-salesman problem> is the problem of determining the
shortest closed tour that connects a given set of I<n> points in the plane.
Figure 15.9(a) shows the solution to a 7-point problem.  The general problem is
NP-complete, and its solution is therefore believed to require more than
polynomial time (see Chapter 34).

J. L. Bentley has suggested[2] that we simplify the problem by restricting our
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

From wikipedia:

=over 4

In computational geometry, a I<bitonic tour> of a set of point sites in the
Euclidean plane is a closed polygonal chain that has each site as one of its
vertices, such that any vertical line crosses the chain at most twice.

=back

=head1 THE SOLUTION

=head2 Dynamic Programming

=head2 Overlapping Subproblems

=head2 Optimal Substructure

=head2 Insight #1

B<The cost structure stores the cost of (i.e. length of) a specific path>.

=over 4

C<cost(i,j)> = the cost of a B<partial bitonic tour> from point C<i> through the leftmost
point to point C<j>.  The fact that this is a bitonic tour implies:

  * all points to the left of C<j> are included in tour(i,j)

=back

=head2 Insight #2



=head2 Recurrence


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




=head1 THIS SOLUTION'S FLAWS


=head1 METHODS

=head2 Algorithm::TravelingSalesman::BitonicTour->new()

Constructs a new C<Algorithm::TravelingSalesman::BitonicTour> solution object.

Example:

    my $ts = Algorithm::TravelingSalesman::BitonicTour->new;

=cut

sub new {
    my $class = shift;
    my %new = (
        _tour   => {},
        _points => {},
    );
    my $self = bless \%new, $class;
    return $self;
}

=head2 $ts->add_point($x,$y)

Adds a point at position (C<$x>, C<$y>) to be included in the solution.  Method
C<add_point()> checks to make sure that no two points have the same
I<x>-coordinate.  This method will C<croak()> with a descriptive error message
if anything goes wrong.

Example:

    # add point at coordinates (x=2, y=3) to the tour
    $ts->add_point(2,3);

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
        $self->_sorted_points(undef);   # clear any previous cache of sorted points
        $self->_points->{$x} = $y;
        return [$x, $y];
    }
}

=head2 $ts->N()

Returns the number of points that have been added to the object.

Example:

    print "I have %d points.\n", $ts->N;

=cut

sub N {
    my $self = shift;
    return scalar keys %{ $self->_points };
}

=head2 $ts->R()

Returns the index of the rightmost point that has been added to the object.
This is always one less than C<< $ts->N >>.

=cut

sub R {
    my $self = shift;
    die 'Problem has no rightmost point (N < 1)' if $self->N < 1;
    return $self->N - 1;
}


=head2 $ts->sorted_points()

Returns an array of points sorted by increasing I<x>-coordinate.  The first
array element is thus the leftmost point in the problem.

Each point is represented as an arrayref containing 2 elements.  The sorted
array of points is cached, but the cache is cleared by each call to
C<add_point()>.

Example:

    my $ts = Algorithm::TravelingSalesman::BitonicTour->new;
    $ts->add_point(1,1);
    $ts->add_point(0,0);
    $ts->add_point(2,0);
    my @sorted = $ts->sorted_points;    # an array of three points

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

=head2 coord($n)

Returns an array containing the coordinates of point C<$n>.

Examples:

    my ($x0, $y0) = $ts->coord(0);   # coordinates of leftmost point
    my ($x1, $y1) = $ts->coord(1);   # coordinates of next point
    # ...
    my ($xn, $yn) = $ts->coord(-1);  # coordinates of rightmost point

=cut

sub coord {
    my ($self, $n) = @_;
    return @{ ($self->sorted_points)[$n] };
}

=head2 $ts->solve()

Solves the problem as configured.  See L</"THE SOLUTION"> above for algorithm
details.

Returns a number equal to the length of the minimum tour.

Example:

    my $tour_length = $ts->solve();

=cut

sub solve {
    my $self = shift;
    my ($length, @points);
    if ($self->N < 1) {
        croak "FAIL: you need to add some points!";
    }
    elsif ($self->N == 1) {
        ($length, @points) = (0, 0);
    }
    else {
        ($length, @points) = $self->optimal_full_tour;
    }
    return ($length, @points);
}

=head2 $ts->optimal_full_tour

Find the length of the optimal complete bitonic tour by finding the minimum
value of

=over 4

min{ i = 0 ..  }( cost(i,N) + delta(i,N) )

=back

=cut

sub optimal_full_tour {
    my $self = shift;
    $self->populate_partial_tours;
    my $R = $self->R;
    my @tours = map {
        my $cost = $self->tour_cost($_,$self->R) + $self->delta($_,$self->R);
        my @points = ($self->tour_points($_,$R), $_);
        [ $cost, @points ];
    } 0 .. $self->R - 1;
    my $tour = reduce { $a->[0] < $b->[0] ? $a : $b } @tours;
    return @$tour;
}

=head2 $ts->populate_partial_tours

Populates internal data structure C<cost($i,$j)> containing optimal partial
tour costs and paths.

=cut

sub populate_partial_tours {
    my $self = shift;

    # Set cost(0,1) is equal to delta(0,1).  This correctness of this cost
    # follows from the problem definition, and doing this simplifies future
    # loop ranges. (I have mixed feelings about this step; it would be nice if
    # this was handled by a more subtle choice of loop indices.)
    $self->tour_cost(0, 1, $self->delta(0,1) );
    $self->tour_points(0, 1, 0, 1);

    # find optimal tours for all points 2, 3, ... up to R
    foreach my $k (2 .. $self->R) {

        # for each point "i" to the left of "k", find (and save) the optimal
        # partial bitonic tour from "i" to "k".
        foreach my $i (0 .. $k - 1) {
            my ($cost, @points) = $self->optimal_partial_tour($i,$k);
            $self->tour_cost($i, $k, $cost);
            $self->tour_points($i, $k, @points);
        }
    }
}

=head2 $ts->optimal_partial_tour($i,$j)

Determines the optimal partial tour from point C<$i> to point C<$j>, based on
the values of previously calculated optimal tours.

Two cases, ($i < $j - 1) and ($i = $j - 1)

    A[i,j] = A[i,j-1] + d(j-1,j)                 if j > i+1
    A[i,j] = min[ k < i ] { A[k,i] + d(k,j) }    if j = i+1

Example:

    # determine the cost of 
    my $cost = $ts->optimal_cost(20,25);

=cut

sub optimal_partial_tour {
    my ($self, $i, $j) = @_;
    local $" = q(,);

    # we want $i to be strictly less than $j (we can actually be more lax with
    # the inputs, but this stricture simplifies things)
    croak "ERROR: bad call, optimal_partial_tour(@_)" unless $i < $j;

    # if $i and $j are adjacent, many valid bitonic tours (i => x => j) are
    # possible; choose the shortest one.
    return $self->_optimal_partial_tour_adjacent($i, $j) if $i + 1 == $j;

    # if $i and $j are NOT adjacent, then only one bitonic tour (i => j-1 => j)
    # is possible.
    return $self->_optimal_partial_tour_nonadjacent($i, $j) if $i + 1 < $j;

    croak "ERROR: bad call, optimal_partial_tour(@_)";
}

=head2 $obj->_optimal_partial_tour_adjacent

If $i and $j are adjacent, many valid bitonic tours (i => x => j) are possible;
choose the shortest one.

=cut

sub _optimal_partial_tour_adjacent {
    my ($self, $i, $j) = @_;
    my @tours = map {
        my $x = $_;
        my $cost = $self->tour_cost($x,$i) + $self->delta($x,$j);
        my @path = reverse($j, $self->tour_points($x, $i) );
        [ $cost, @path ];
    } 0 .. $i - 1;
    my $min_tour = reduce { $a->[0] < $b->[0] ? $a : $b } @tours;
    return @$min_tour;
}

=head2 $obj->_optimal_partial_tour_nonadjacent

If $i and $j are not adjacent, then only one valid partial bitonic tour
(C<< i => j-1 => j >>) exists.

FIXME: need pointer to documentation!

=cut

sub _optimal_partial_tour_nonadjacent {
    my ($self, $i, $j) = @_;
    my $cost = $self->tour_cost($i, $j - 1)+ $self->delta($j - 1,$j);
    my @points = ($self->tour_points($i, $j - 1), $j);
    return($cost, @points);
}


=head2 $b->tour($i, $j, [%tour])

Returns the structure associated with the optimal bitonic tour from point C<$i>
to C<$j>.  This is a hashref with keys C<cost> and C<points>.

=cut

sub tour {
    my ($self, $i, $j) = @_;
    croak "ERROR: tour($i,$j) ($i >= $j)" unless $i < $j;
    $self->_tour->{$i}{$j} = {} unless $self->_tour->{$i}{$j};
    return $self->_tour->{$i}{$j};
}

=head2 $b->tour_cost($i,$j,[$cost])

Returns the cost of the bitonic tour from point C<$i> to C<$j>.

=cut

sub tour_cost {
    my $self = shift;
    my $i    = shift;
    my $j    = shift;
    croak "ERROR: tour_cost($i,$j,...) ($j >= @{[ $self->N ]})"
        unless $j < $self->N;
    if (@_) {
        croak "ERROR: tour_cost($i,$j,$_[0]) has cost <= 0 ($_[0])"
            unless $_[0] > 0;
        $self->tour($i,$j)->{cost} = $_[0];
    }
    if (exists $self->tour($i,$j)->{cost}) {
        return $self->tour($i,$j)->{cost};
    }
    else {
        croak "Don't know the cost of tour($i,$j)";
    }
}

=head2 $b->tour_points($i,$j, [@points])

Returns the points in the bitonic tour from point C<$i> to C<$j>.

=cut

sub tour_points {
    my $self = shift;
    my $i    = shift;
    my $j    = shift;
    if (@_) {
        croak "ERROR: tour_points($i,$j,@_) ($i != first point)"
            unless $i == $_[0];
        croak "ERROR: tour_points($i,$j,@_) ($j != last point)"
            unless $j == $_[-1];
        $self->tour($i,$j)->{points} = [ @_ ];
    }
    if (exists $self->tour($i,$j)->{points}) {
        return @{ $self->tour($i,$j)->{points} };
    }
    else {
        croak "Don't know the points for tour($i,$j)";
    }
}

=head2 $b->delta($n1,$n2);

Returns the euclidean distance from point C<$n1> to point C<$n2>.

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
    return sqrt((($x1-$x2)*($x1-$x2))+(($y1-$y2)*($y1-$y2)));
}


=head1 RESOURCES

=over 4

=item [1]

Cormen, Thomas H.; Leiserson, Charles E.; Rivest, Ronald L.; Stein, Clifford
(2001). Introduction to Algorithms, second edition, MIT Press and McGraw-Hill.
ISBN 978-0-262-53196-2. 

=item [2]

Bentley, Jon L. (1990), "Experiments on traveling salesman heuristics", Proc.
1st ACM-SIAM Symp. Discrete Algorithms (SODA), pp. 91-99,
L<http://portal.acm.org/citation.cfm?id=320186>.

=item [3]

L<http://en.wikipedia.org/wiki/Bitonic_tour>

=item [4]

L<http://en.wikipedia.org/wiki/Traveling_salesman_problem>

=item [5]

L<http://www.tsp.gatech.edu/>

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

