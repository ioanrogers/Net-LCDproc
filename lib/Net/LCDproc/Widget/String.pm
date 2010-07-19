package Net::LCDproc::Widget::String;

use v5.10.0;
use Moose;

extends 'Net::LCDproc::Widget';

use namespace::autoclean;

sub BUILD {
    my $self = shift;
    $self->_set_cmd( [ qw/ x y text /])
}

has type => (
    is      => 'ro',
    isa     => 'Str',
    default => 'string',
);

has text => (
    is      => 'rw',
    isa     => 'Str',
    required => 1,
    default  => '',
    trigger => sub {
        $_[0]->has_changed;
    },
);

has [ 'x', 'y' ] => (
    is      => 'rw',
    isa     => 'Int',
    required => 1,
    default  => 1,
    trigger =>  sub {
        $_[0]->has_changed;
    },
);

has _set_cmd => (
    is  => 'rw',
    isa => 'ArrayRef',
);

no Moose;

__PACKAGE__->meta->make_immutable;

1;

