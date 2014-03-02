package Net::LCDproc::Widget::Title;

#ABSTRACT: 'title' widget

use v5.10.2;
use Moose;
use namespace::autoclean;

extends 'Net::LCDproc::Widget';

has text => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

has '+_set_cmd' => ( default => sub { [qw/ text /] } );

__PACKAGE__->meta->make_immutable;

1;

