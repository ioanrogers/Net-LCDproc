package Net::LCDproc::Meta::Widget;

# ABSTRACT: Handles the state of widgets

use v5.10.2;
use Moose qw//;
use Moose::Exporter;

Moose::Exporter->setup_import_methods(
    class_metaroles => {
        attribute => ['Net::LCDproc::Meta::Role::Widget'],

    },
    role_metaroles =>
      {applied_attribute => ['Net::LCDproc::Meta::Role::Widget'],},

);

package Net::LCDproc::Meta::Role::Widget;

use Moose::Role;

before '_process_options' => sub {
    my ($self, $name, $options) = @_;

    if (exists $options->{traits} && grep {'NoState'} @{$options->{traits}}) {
        return;
    }

    if ($name eq 'id') {

        # this is immutable
        return;
    }

    if (exists $options->{trigger}) {

        # shouldn't be another trigger
        return;
    }

    $options->{trigger} = sub {
        shift->has_changed;
    };
};

package Net::LCDproc::Meta::Widget::Trait::NoState;
use Moose::Role;
no Moose::Role;

package Moose::Meta::Attribute::Custom::Trait::NoState;
sub register_implementation {'Net::LCDproc::Meta::Widget::Trait::NoState'}

1;
