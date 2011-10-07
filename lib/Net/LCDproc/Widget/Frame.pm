package Net::LCDproc::Widget::Frame;

# ABSTRACT: 'frame' widget

use v5.10.0;
use Moose;
use Moose::Util::TypeConstraints;
extends 'Net::LCDproc::Widget';

use namespace::autoclean;

no Moose;

__PACKAGE__->meta->make_immutable;

1;

