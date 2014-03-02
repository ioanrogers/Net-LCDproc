package Net::LCDproc::Widget::Icon;

#ABSTRACT: 'icon' widget

use v5.10.2;
use Moose;
use Moose::Util::TypeConstraints;
use namespace::autoclean;

extends 'Net::LCDproc::Widget';

has iconname => (
    is  => 'rw',
    isa => enum([
            qw/
              BLOCK_FILLED
              HEART_OPEN
              HEART_FILLED
              ARROW_UP
              ARROW_DOWN
              ARROW_LEFT
              ARROW_RIGHT
              CHECKBOX_OFF
              CHECKBOX_ON
              CHECKBOX_GRAY
              SELECTOR_AT_LEFT
              SELECTOR_AT_RIGHT
              ELLIPSIS
              STOP
              PAUSE
              PLAY
              PLAYR
              FF
              FR
              NEXT
              PREV
              REC
              NULL
              /
        ]
    ),
    required => 1,
);

has ['x', 'y'] => (
    is       => 'rw',
    isa      => 'Int',
    required => 1,
);

has '+_set_cmd' => ( default => sub { [qw/ x y iconname /] } );

__PACKAGE__->meta->make_immutable;

1;

