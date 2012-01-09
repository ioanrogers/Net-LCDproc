package Net::LCDproc::Widget::Frame;

#ABSTRACT: The 'frame' widget, a screen within a screen

use v5.10;
use Moose;
use Moose::Util::TypeConstraints;
use namespace::autoclean;
extends 'Net::LCDproc::Widget';

__PACKAGE__->meta->make_immutable;

1;
