package Net::LCDproc::Widget::Title;

#ABSTRACT: 'title' widget

use v5.10;
use Moose;
use namespace::autoclean;

extends 'Net::LCDproc::Widget';

sub BUILD {
    my $self = shift;
    $self->_set_cmd( [qw/ text /] );
}

has type => (
    is      => 'ro',
    isa     => 'Str',
    default => 'title',
);

has text => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
    lazy     => 1,
    default  => '',
    trigger  => sub {
        $_[0]->has_changed;
    },
);

__PACKAGE__->meta->make_immutable;

1;

