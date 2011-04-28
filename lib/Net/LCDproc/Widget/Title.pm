package Net::LCDproc::Widget::Title;

use v5.10.0;
use Moose;

extends 'Net::LCDproc::Widget';

use namespace::autoclean;

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

no Moose;

__PACKAGE__->meta->make_immutable;

1;

