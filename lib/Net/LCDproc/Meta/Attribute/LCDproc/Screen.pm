package Net::LCDproc::Meta::Attribute::LCDproc::Screen;

use 5.0100;
use Moose::Role;
use Moose::Util::TypeConstraints;

has changed => (
    traits  => ['Bool'],
    is      => 'rw',
    isa     => 'Bool',
    handles => {
        is_changed     => 'set',
        change_updated => 'unset',
    },
);

has cmd_str => (
    is        => 'ro',
    isa       => 'Str',
    predicate => 'has_cmd_str',
);

no Moose::Util::TypeConstraints;
no Moose::Role;

package Moose::Meta::Attribute::Custom::Trait::LCDprocScreen;

sub register_implementation { 'Net::LCDproc::Meta::Attribute::LCDproc::Screen' }

1;
