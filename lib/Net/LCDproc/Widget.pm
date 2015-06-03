package Net::LCDproc::Widget;

#ABSTRACT: Base class for all the widgets

use v5.10.2;
use Log::Any qw($log);
use Types::Standard qw/ArrayRef Bool InstanceOf Str/;
use Moo;
use namespace::clean;

has id => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has type => (
    is      => 'ro',
    isa     => Str,
    traits  => ['NoState'],
    default => sub {
        my $pkg = ref $_[0];
        my @parts = split /::/, $pkg;
        return lc $parts[-1];
    },
);

has frame_id => (
    is        => 'rw',
    isa       => Str,
    predicate => 'has_frame_id',

    #isa => 'Net::LCDproc::Widget::Frame',
);

has screen => (
    is  => 'rw',
    isa => InstanceOf ['Net::LCDproc::Screen'],
);

has is_new => (
    is      => 'rw',
    isa     => Bool,
    default => 1,
);

has changed => (
    is  => 'rw',
    isa => Bool,
);

has _set_cmd => (
    is       => 'rw',
    isa      => ArrayRef,
    required => 1,
    default  => sub { [] },
);

### Public Methods

sub update {
    my $self = shift;

    if ($self->is_new) {

        # needs to be added
        $self->_create_widget_on_server;
    }

    if (!$self->changed) {
        return;
    }
    $log->debug('Updating widget: ' . $self->id) if $log->is_debug;
    my $cmd_str = $self->_get_set_cmd_str;

    $self->screen->_lcdproc->_send_cmd($cmd_str);

    $self->changed(0);
    return 1;
}

# removes this widget from the LCDproc server, unhooks from $self->server, then destroys itself
sub remove {
    my $self = shift;

    my $cmd_str = sprintf 'widget_del %s %s', $self->screen->id, $self->id;
    $self->_lcdproc->_send_cmd($cmd_str);

    return 1;
}

### Private Methods
sub _get_set_cmd_str {
    my ($self) = @_;

    my $cmd_str = sprintf 'widget_set %s %s', $self->screen->id, $self->id;

    foreach my $attr (@{$self->_set_cmd}) {
        $cmd_str .= sprintf ' "%s"', $self->$attr;
    }

    return $cmd_str;

}

sub _create_widget_on_server {
    my $self = shift;
    $log->debugf('Adding new widget: %s - %s', $self->id, $self->type);
    my $add_str = sprintf 'widget_add %s %s %s',
      $self->screen->id, $self->id, $self->type;

    if ($self->has_frame_id) {
        $add_str .= " -in " . $self->frame_id;
    }
    $self->screen->_lcdproc->_send_cmd($add_str);

    $self->is_new(0);

    # make sure it gets set
    $self->changed(1);
    return 1;
}

1;
