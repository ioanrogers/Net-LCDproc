#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

my @classes = qw/ Net::LCDproc::Screen Net::LCDproc::Widget::Title /;

my $num_tests = 2 + ( ( scalar @classes ) * 2 );

plan tests => $num_tests;

# LCDproc doesn't require any args
{
    use_ok('Net::LCDproc');
    new_ok('Net::LCDproc')
}

foreach my $class (@classes) {
    use_ok($class);
    new_ok( $class => [ id => 'test' ] );
}

