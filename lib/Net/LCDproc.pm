package Net::LCDproc;

#ABSTRACT: Client library to interact with L<LCDproc|http://lcdproc.sourceforge.net/>

use v5.10.2;
use Moo 1.001000;

use Net::LCDproc::Error;
use Net::LCDproc::Screen;
use Net::LCDproc::Widget::HBar;
use Net::LCDproc::Widget::Icon;
use Net::LCDproc::Widget::Num;
use Net::LCDproc::Widget::Scroller;
use Net::LCDproc::Widget::String;
use Net::LCDproc::Widget::Title;
use Net::LCDproc::Widget::VBar;

use Log::Any qw($log);
use IO::Socket::INET;
use Const::Fast;
use Types::Standard qw/ArrayRef HashRef InstanceOf Int Str/;
use namespace::sweep;

no if $] >= 5.018, 'warnings', 'experimental::smartmatch';

const my $PROTOCOL_VERSION => 0.3;
const my $MAX_DATA_READ    => 4096;

sub BUILD {
    my $self = shift;
    $self->_send_hello;
    return 1;
}

sub DEMOLISH {
    my $self = shift;
    if ($self->has_socket && defined $self->socket) {
        $log->debug('Shutting down socket') if $log->is_debug;
        $self->socket->shutdown('2');
    }
    return 1;
}

has server => (
    is            => 'ro',
    isa           => Str,
    default       => 'localhost',
    documentation => 'Hostname or IP address of LCDproc server',
);

has port => (
    is            => 'ro',
    isa           => Int,
    default       => 13666,
    documentation => 'Port the LCDproc server is listening on',
);

has ['width', 'height'] => (
    is            => 'rw',
    isa           => Int,
    documentation => 'Dimensions of the display in cells',
);

has ['cell_width', 'cell_height'] => (
    is            => 'rw',
    isa           => Int,
    documentation => 'Dimensions of a cell in pixels',
);

has screens => (
    is            => 'rw',
    isa           => ArrayRef [InstanceOf ['Net::LCDproc::Screen']],
    documentation => 'Array of active screens',
    default => sub { [] },
);

has socket => (
    is  => 'lazy',
    predicate => 1,
    isa => InstanceOf ['IO::Socket::INET'],
);

has responses => (
    is       => 'ro',
    isa      => HashRef,
    required => 1,
    default  => sub {
        return {
            connect =>
              qr{^connect LCDproc (\S+) protocol (\S+) lcd wid (\d+) hgt (\d+) cellwid (\d+) cellhgt (\d+)$},
            success => qr{^success$},
            error   => qr{^huh\?\s(.+)$},
            listen  => qr{^listen\s(.+)$},
            ignore  => qr{^ignore\s(.+)$},
        };
    },
);

sub _build_socket {
    my $self = shift;

    $log->debug('Connecting to server');

    my $socket = IO::Socket::INET->new(
        PeerAddr  => $self->server,
        PeerPort  => $self->port,
        ReuseAddr => 1,
    );

    if (!defined $socket) {

        Net::LCDproc::Error->throwf(
            'Failed to connect to lcdproc server at "%s:%s": %s',
            $self->server, $self->port, $!,);
    }

    return $socket;
}

sub _send_cmd {
    my ($self, $cmd) = @_;

    $log->debug("Sending '$cmd'") if $log->is_debug;

    my $ret = $self->socket->send($cmd . "\n");
    if (!defined $ret) {
        Net::LCDproc::Error->throw("Error sending cmd '$cmd': $!");
    }

    my $response = $self->_handle_response;

    #if (ref $response eq 'Array') {
    return $response;

}

sub _recv_response {
    my $self = shift;
    $self->socket->recv(my $response, $MAX_DATA_READ);

    if (!defined $response) {
        Net::LCDproc::Error->throw("No response from lcdproc: $!");
    }

    chomp $response;
    $log->debug("Received '$response'");

    return $response;
}

sub _handle_response {
    my $self = shift;

    my $response_str = $self->_recv_response;
    my $matched;
    my @args;
    foreach my $msg (keys %{$self->responses}) {
        if (@args = $response_str =~ $self->responses->{$msg}) {
            $matched = $msg;
            last;
        }
    }

    if (!$matched) {
        say "Invalid/Unknown response from server: '$response_str'";
        return;
    }

    given ($matched) {
        when (/error/) {
            $log->error('ERROR: ' . $args[0]);
            return;
        }
        when (/connect/) {
            return \@args;
        }
        when (/success/) {
            return 1;
        }
        default {

            # don't care about listen or ignore
            # so find something useful to return
            # FIXME: start caring! Then only update the server when
            # it is actually listening
            return $self->_handle_response;
        }
    }

}

sub _send_hello {
    my $self = shift;

    my $response = $self->_send_cmd('hello');

    if (!ref $response eq 'ARRAY') {
        Net::LCDproc::Error->throw('Failed to read connect string');
    }
    my $proto = $response->[1];

    $log->infof('Connected to LCDproc version %s, proto %s',
        $response->[0], $proto);
    if ($proto != $PROTOCOL_VERSION) {
        Net::LCDproc::Error->throwf(
            'Unsupported protocol version. Available: %s Supported: %s',
            $proto, $PROTOCOL_VERSION);
    }
    ## no critic (ProhibitMagicNumbers)
    $self->width($response->[2]);
    $self->height($response->[3]);
    $self->cell_width($response->[4]);
    $self->cell_height($response->[5]);
    ## use critic
    return 1;
}

sub add_screen {
    my ($self, $screen) = @_;
    $screen->_lcdproc($self);
    push @{$self->screens}, $screen;
    return 1;
}

sub remove_screen {
    my ($self, $screen) = @_;
    my $i = 0;
    foreach my $s (@{$self->screens}) {
        if ($s == $screen) {
            $log->debug("Removing $s") if $log->is_debug;
            splice @{$self->screens}, $i, 1;
            return 1;
        }
        $i++;
    }
    $log->error('Failed to remove screen');
    return;

}

# updates the screen on the server
sub update {
    my $self = shift;
    foreach my $s (@{$self->screens}) {
        $s->update;
    }
    return 1;
}

1;

=head1 SYNOPSIS

  use Net::LCDproc; # this loads all the mods under Net::LCDproc::*

  my $lcdproc = Net::LCDproc->new;
  my $screen = Net::LCDproc::Screen->new(id => 'main');

  my $title = Net::LCDproc::Widget::Title->new(id => 'title');
  $title->text('My Screen Title');
  $lcdproc->add_screen($screen);

  $screen->set('name',      'Test Screen');
  $screen->set('heartbeat', 'off');

  $screen->add_widget($title);

  my $wdgt = Net::LCDproc::Widget::String->new(
      id   => 'wdgt',
      x    => 1,
      y    => 2,
      text => 'Some Text',
  );

  $screen->add_widget($wdgt);

  while (1) {
      # update your widgets here ...
      $lcdproc->update; # only changed widgets are updated
      sleep(1);
  }

=head1 SEE ALSO

L<LCDproc|http://lcdproc.sourceforge.net/>
