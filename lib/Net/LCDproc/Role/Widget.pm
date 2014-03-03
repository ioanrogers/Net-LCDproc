package Net::LCDproc::Role::Widget;

use Moo::Role;

sub _set_attr {
    $_[0]->changed(1);
    return 1;
}

1;
