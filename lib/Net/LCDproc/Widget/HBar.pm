package Net::LCDproc::Widget::HBar;

#ABSTRACT: 'hbar' widget

use v5.10;
use Moose;
use namespace::autoclean;

extends 'Net::LCDproc::Widget';

has ['x', 'y', 'length'] => (
    is       => 'rw',
    isa      => 'Int',
    required => 1,
    default  => 0,
    trigger  => sub {
        $_[0]->has_changed;
    },
);

has '+type' => (default => 'hbar',);

has '+_set_cmd' => (default => sub { [qw/ x y length /] },);

__PACKAGE__->meta->make_immutable;

1;

