package Net::LCDproc::Widget::String;

#ABSTRACT: show regular strings

use v5.10;
use Moose;
use namespace::autoclean;

extends 'Net::LCDproc::Widget';

has text => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

has ['x', 'y'] => (
    is       => 'rw',
    isa      => 'Int',
    required => 1,
);

has '+_set_cmd' => ( default => sub { [qw/ x y text /] } );

__PACKAGE__->meta->make_immutable;

1;

