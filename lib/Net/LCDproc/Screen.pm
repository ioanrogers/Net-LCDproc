package Net::LCDproc::Screen;

#ABSTRACT: represents an LCDproc screen

use v5.10.2;
use Moo;
use Types::Standard qw/ArrayRef Bool Enum HashRef InstanceOf Int Str/;
use Log::Any qw($log);
use namespace::sweep;

has id => (is => 'ro', isa => Str, required => 1);

has name => (is => 'rwp', isa => Str);

has [qw/width height duration timeout cursor_x cursor_y/] => (
    is  => 'rwp',
    isa => Int,
);

has priority => (
    is  => 'rwp',
    isa => Enum([qw[hidden background info foreground alert input]]),
);

has heartbeat => (
    is  => 'rwp',
    isa => Enum([qw[on off open]]),
);

has backlight => (
    is  => 'rwp',
    isa => Enum([qw[on off open toggle blink flash ]]),
);

has cursor => (
    is  => 'rwp',
    isa => Enum([qw[on off under block]]),
);

has widgets => (
    is  => 'rw',
    isa => ArrayRef [InstanceOf ['Net::LCDproc::Widget']],
    default => sub { [] },
);

has is_new => (is => 'rw', isa => Bool, default  => 1);

has _lcdproc => (is => 'rw', isa => InstanceOf['Net::LCDproc']);

has _state => (is => 'ro', isa => HashRef, default => sub {{}});

=method C<set($attr, $val)>

Assign a new value to a screen attribute.

=cut

sub set {
    my ($self, $attr, $val) = @_;

    # set the attribute
    my $setter = "_set_$attr";
    $self->$setter($val);

    # and record it is dirty
    $self->_state->{$attr} = 1;
    return 1;
}

# updates the screen on the server
sub update {
    my $self = shift;

    if ($self->is_new) {

        # screen needs to be added
        if ($log->is_debug) { $log->debug('Adding ' . $self->id) }
        $self->_lcdproc->_send_cmd('screen_add ' . $self->id);
        $self->is_new(0);
    }

    # even if the screen was new, we leave defaults up to the LCDproc server
    # so nothing *has* to be set

    foreach my $attr (keys %{$self->_state}) {
        $log->debug('Updating screen: ' . $self->id) if $log->is_debug;

        my $cmd_str = $self->_get_cmd_str_for($attr);

        $self->_lcdproc->_send_cmd($cmd_str);
        delete $self->_state->{$attr};
    }

    # now check the the widgets attached to this screen
    foreach my $widget (@{$self->widgets}) {
        $widget->update;
    }
    return 1;
}

# TODO accept an arrayref of widgets
sub add_widget {
    my ($self, $widget) = @_;
    $widget->screen($self);
    push @{$self->widgets}, $widget;
    return 1;
}

# removes screen from N::L, deletes from server, then cascades and kills its widgets (optionally not)
sub remove {
    my ($self, $keep_widgets) = @_;

    if (!defined $keep_widgets) {
        foreach my $widget (@{$self->widgets}) {
            $widget->remove;
        }
    }
    return 1;
}

### Private Methods

sub _get_cmd_str_for {
    my ($self, $attr) = @_;

    my $cmd_str = 'screen_set ' . $self->id;

    $cmd_str .= sprintf ' %s "%s"', $attr, $self->$attr;
    return $cmd_str;
}

1;
