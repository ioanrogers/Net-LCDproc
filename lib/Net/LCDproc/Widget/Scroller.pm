package Net::LCDproc::Widget::Scroller;

#ABSTRACT: 'scroller' widget

use v5.10;
use Moose;
use Moose::Util::TypeConstraints;
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

has direction => (
    is       => 'rw',
    isa      => enum([qw/h v m/]),
    required => 1,
    default  => 'h',
    trigger  => sub {
        $_[0]->has_changed;
    },
);

has ['left', 'right', 'top', 'bottom', 'speed'] => (
    is       => 'rw',
    isa      => 'Int',
    required => 1,
    default  => 0,
    trigger  => sub {
        $_[0]->has_changed;
    },
);


has '+_set_cmd' =>
  (default => sub { [qw/ left top right bottom direction speed text /] },);

__PACKAGE__->meta->make_immutable;

1;

