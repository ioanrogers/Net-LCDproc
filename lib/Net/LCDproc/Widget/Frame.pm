package Net::LCDproc::Widget::Frame;

#ABSTRACT: A frame, a screen within a screen

use v5.10.2;
use Moo;
use Types::Standard qw/Enum Int/;
use namespace::sweep;
extends 'Net::LCDproc::Widget';

has direction => (
    is       => 'rw',
    isa      => Enum(['v', 'h']),
    required => 1,
    trigger  => \&_set_attr,
);

has ['left', 'right', 'top', 'bottom', 'width', 'height', 'speed'] => (
    is       => 'rwp',
    isa      => Int,
    required => 1,
    trigger  => \&_set_attr,
);

has '+_set_cmd' =>
  (default => sub { [qw/left top right bottom width height direction speed/] },
  );

1;

=head1 ATTRIBUTES

All atrributes are required

=over

=item direction

C<h> or C<v> for horizontal or vertical scrolling, respectively. In practice,
horizontal scrolling is marked as TODO in LCDproc.

=item left, right, top, bottom

Coordinates of the frame on the screen in chars

=item width, height

Frame dimension in chars

=item speed

Speed of scrolling, if needed

=back

