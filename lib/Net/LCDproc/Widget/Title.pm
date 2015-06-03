package Net::LCDproc::Widget::Title;

#ABSTRACT: 'title' widget

use v5.10.2;
use Types::Standard qw/Str/;
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

has '+_set_cmd' => ( default => sub { [qw/ text /] } );

1;
