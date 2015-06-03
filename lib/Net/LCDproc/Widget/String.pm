package Net::LCDproc::Widget::String;

#ABSTRACT: show regular strings

use v5.10.2;
use Types::Standard qw/Int Str/;
use Moo;
use namespace::clean;

extends 'Net::LCDproc::Widget';
with 'Net::LCDproc::Role::Widget';

has text => (
    is       => 'rw',
    isa      => Str,
    required => 1,
    trigger  => \&_set_attr,
);

has ['x', 'y'] => (
    is       => 'rw',
    isa      => Int,
    required => 1,
    trigger  => \&_set_attr,
);

has '+_set_cmd' => ( default => sub { [qw/ x y text /] } );

1;
