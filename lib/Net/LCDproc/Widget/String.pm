package Net::LCDproc::Widget::String;

#ABSTRACT: 'string' widget

use v5.10;
use Moose;
use namespace::autoclean;

extends 'Net::LCDproc::Widget';

sub BUILD {
    my $self = shift;

    # $self->_set_type( 'string' ); # TODO: get type from lc packagename
    $self->_set_cmd( [qw/ x y text /] );
}

has text => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
    default  => '',
    trigger  => sub {
        $_[0]->has_changed;
    },
);

has [ 'x', 'y' ] => (
    is       => 'rw',
    isa      => 'Int',
    required => 1,
    default  => 1,
    trigger  => sub {
        $_[0]->has_changed;
    },
);

__PACKAGE__->meta->make_immutable;

1;

