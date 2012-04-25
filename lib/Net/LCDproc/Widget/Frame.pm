package Net::LCDproc::Widget::Frame;

#ABSTRACT: A frame, a screen within a screen

use v5.10;
use Moose;
use Moose::Util::TypeConstraints;
use namespace::autoclean;
extends 'Net::LCDproc::Widget';

has direction => (
    is       => 'rw',
    isa      => enum(['v', 'h']),
    required => 1,
);

has ['left', 'right', 'top', 'bottom', 'width', 'height', 'speed'] => (
    is       => 'rw',
    isa      => 'Int',
    required => 1,
);

has '+_set_cmd' => (default => sub { [qw/left top right bottom width height direction speed/] },);

__PACKAGE__->meta->make_immutable;

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
