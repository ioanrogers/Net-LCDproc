package Net::LCDproc::Widget;

use v5.10.0;
use Moose;

use YAML::XS;

use namespace::autoclean;

has id => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has frame => (
    is  => 'ro',
    isa => 'Net::LCDproc::Widget::Frame',
);

has screen => (
    is  => 'rw',
    isa => 'Net::LCDproc::Screen',
);

has _conn => (
    is       => 'rw',
    isa      => 'Net::LCDproc::Net',
    required => 0,
);

has is_new => (
    traits   => ['Bool'],
    is       => 'ro',
    isa      => 'Bool',
    default  => 1,
    required => 1,
    handles  => { added => 'unset', },
);

has changed => (
    traits  => ['Bool'],
    is      => 'rw',
    isa     => 'Bool',
    handles => {
        has_changed     => 'set',
        change_updated => 'unset',
    },
);

has _set_cmd => (
    is  => 'rw',
    isa => 'ArrayRef',
);

### Public Methods

sub set {
    my ( $self, $attr_name, $new_val ) = @_;

    say sprintf "Setting %s: '%s'", $attr_name, $new_val;
    my $attr = $self->meta->get_attribute($attr_name);
    $attr->set_value( $self, $new_val );
    $self->is_changed;
}

sub update {
    my $self = shift;

    if ( $self->is_new ) {
        # needs to be added
        $self->_create_widget_on_server;
    }

    if (!$self->changed) {
        return;
    }
    #say "Updating widget: " . $self->id;    
    my $cmd_str = $self->_get_set_cmd_str;

    $self->_conn->_send_cmd($cmd_str);
    my $response = $self->_conn->_recv_response();

    $self->change_updated;
}

# removes this widget from the LCDproc server, unhooks from $self->server, then destroys itself
sub delete {
    my $self = shift;
}

### Private Methods
sub _get_set_cmd_str {
    my ( $self) = @_;

    my $cmd_str = sprintf "widget_set %s %s", $self->screen->id, $self->id;
    
    foreach my $name ( @{$self->_set_cmd} ) {
        my $attr = $self->meta->get_attribute($name);
        my $val = $attr->get_value($self);
        # should only ever be Str or Int
        if ( $attr->type_constraint eq 'Str' ) {
            $cmd_str .= " \"$val\"";
        } else {
            $cmd_str .= " $val";
        }
    }
    
    return $cmd_str;

}

sub _create_widget_on_server {
    my $self = shift;
    say "Adding new widget";
    $self->_conn->_send_cmd( sprintf "widget_add %s %s %s",
    $self->screen->id, $self->id, $self->type );
    my $response = $self->_conn->_recv_response();
    #$response = $self->_conn->_recv_response();
    $self->added;
    # make sure it gets set
    $self->has_changed;
        
}



no Moose;

__PACKAGE__->meta->make_immutable;

1;

