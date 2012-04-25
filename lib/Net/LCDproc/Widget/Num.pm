package Net::LCDproc::Widget::Num;

#ABSTRACT: 'num' widget

use v5.10;
use Moose;
use namespace::autoclean;

extends 'Net::LCDproc::Widget';

has ['x', 'int'] => (
    is       => 'rw',
    isa      => 'Int',
    required => 1,
    default  => 1,
    trigger  => sub {
        $_[0]->has_changed;
    },
);

has '+_set_cmd' => (default => sub { [qw/ x int /] },);

__PACKAGE__->meta->make_immutable;

1;

