package Net::LCDproc::Widget::String;

#ABSTRACT: 'string' widget

use v5.10;
use Moose;
use namespace::autoclean;

extends 'Net::LCDproc::Widget';

has text => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
    default  => q{},
    trigger  => sub {
        $_[0]->has_changed;
    },
);

has [ 'x', 'y' ] => (
    is       => 'rw',
    isa      => 'Int',
    required => 1,
    default  => 1,
    trigger  => sub {
        $_[0]->has_changed;
    },
);

has '+type' => (
    default => 'string',
);

has '+_set_cmd' => (
    default => sub {[qw/ x y text /]},
);

__PACKAGE__->meta->make_immutable;

1;

