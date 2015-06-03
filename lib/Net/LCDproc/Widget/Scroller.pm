package Net::LCDproc::Widget::Scroller;

#ABSTRACT: 'scroller' widget

use v5.10.2;
use Types::Standard qw/Enum Int Str/;
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

has direction => (
    is       => 'rw',
    isa      => Enum([qw/h v m/]),
    required => 1,
    trigger  => \&_set_attr,
);

has ['left', 'right', 'top', 'bottom', 'speed'] => (
    is       => 'rw',
    isa      => Int,
    required => 1,
    trigger  => \&_set_attr,
);

has '+_set_cmd' =>
  (default => sub { [qw/ left top right bottom direction speed text /] },);

1;
