use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Algorithm::TravelingSalesman::BitonicTour',
    license             => 'perl',
    dist_author         => 'John Trammell <johntrammell@gmail.com>',
    dist_version_from   => 'lib/Algorithm/TravelingSalesman/BitonicTour.pm',
    requires => {
        'Class::Accessor::Fast' => 0,
        'List::Util' => 0,
        'Params::Validate' => 0,
    },
    build_requires => {
        'Pod::Coverage' => 0,
        'Test::More' => 0,
        'Test::Pod' => 0,
        'Test::Pod::Coverage' => 0,
    },
    add_to_cleanup      => [qw(Algorithm-* *.bak)],
);

$builder->create_build_script;
