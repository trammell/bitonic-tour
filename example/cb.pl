#!perl

use strict;
use warnings;
use Cormen::Bitonic;

my $b = Cormen::Bitonic->new;
while (<>) {
    next if /^#/;
    next unless /\S/;
    $b->add_point(split ' ', $_);
}

print $b->solve;

