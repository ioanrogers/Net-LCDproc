package Net::LCDproc::Role::Widget;

use Moo::Role;

sub _set_attr {
    my ($self, $new_val) = @_;

    #    $log->debugf('Setting %s: "%s"', $attr, $new_val) if $log->is_debug;

    $self->changed(1);

    return 1;
}

1;
