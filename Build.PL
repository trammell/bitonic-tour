use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Cormen::Bitonic',
    license             => 'perl',
    dist_author         => 'John Trammell <johntrammell@gmail.com>',
    dist_version_from   => 'lib/Cormen/Bitonic.pm',
    build_requires => {
        'Pod::Coverage' => 0,
        'Test::More' => 0,
        'Test::Pod' => 0,
        'Test::Pod::Coverage' => 0,
    },
    add_to_cleanup      => [ 'Cormen-Bitonic-*', '*.bak' ],
);

$builder->create_build_script();
