package Net::LCDproc::Meta::Screen;

# ABSTRACT: Attributes for the Screen

use v5.10;
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

package Moose::Meta::Attribute::Custom::Trait::LCDprocScreen;
sub register_implementation {'Net::LCDproc::Meta::Screen'}

1;
