package Net::LCDproc::Widget::Icon;

#ABSTRACT: 'icon' widget

use v5.10.2;
use Types::Standard qw/Enum Int/;
use Moo;
use namespace::clean;

extends 'Net::LCDproc::Widget';
with 'Net::LCDproc::Role::Widget';

has iconname => (
    is  => 'rw',
    isa => Enum([
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
    trigger  => \&_set_attr,
);

has ['x', 'y'] => (
    is       => 'rw',
    isa      => Int,
    required => 1,
    trigger  => \&_set_attr,
);

has '+_set_cmd' => ( default => sub { [qw/ x y iconname /] } );

1;
