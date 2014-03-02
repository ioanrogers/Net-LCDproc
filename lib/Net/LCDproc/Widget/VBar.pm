package Net::LCDproc::Widget::VBar;

#ABSTRACT: draw a vertical bar

use v5.10.2;
use Moose;
use namespace::autoclean;

extends 'Net::LCDproc::Widget';

has ['x', 'y', 'length'] => (
    is       => 'rw',
    isa      => 'Int',
    required => 1,
);

has '+_set_cmd' => ( default => sub { [qw/ x y length /] } );

__PACKAGE__->meta->make_immutable;

1;

