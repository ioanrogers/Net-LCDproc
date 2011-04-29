package Net::LCDproc::Net;

use 5.0100;
use Moose;
use Net::LCDproc::Error;
use Log::Any qw($log);
use IO::Socket::INET;
use Readonly;

Readonly my $MAX_DATA_READ => 4096;

sub DEMOLISH {
    my $self = shift;
    if ( $self->has_socket && defined $self->socket ) {
        $log->debug('Shutting down socket') if $log->is_debug;
        $self->socket->shutdown('2');
    }
    return;
}

has server => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has port => (
    is       => 'ro',
    isa      => 'Int',
    required => 1,
);

has socket => (
    is        => 'rw',
    isa       => 'IO::Socket::INET',
    predicate => 'has_socket',
);

has responses => (
    is       => 'ro',
    isa      => 'HashRef',
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

sub connect_to_lcdproc {
    my $self = shift;

    my $socket = IO::Socket::INET->new(
        PeerAddr  => $self->server,
        PeerPort  => $self->port,
        ReuseAddr => 1,
    );

    if ( !defined $socket ) {

        Net::LCDproc::Error->throwf( 'Failed to connect to lcdproc server at "%s:%s": %s',
            $self->server, $self->port, $!, );
    }

    $self->socket($socket);
    return 1;

}

sub send_cmd {
    my ( $self, $cmd ) = @_;

    $log->debug("Sending '$cmd'") if $log->is_debug;

    my $ret = $self->socket->send($cmd . "\n");
    if ( !defined $ret ) {
        Net::LCDproc::Error->throw("Error sending cmd '$cmd': $!");
    }

    my $response = $self->_handle_response;

    #if (ref $response eq 'Array') {
    return $response;

}

sub recv_response {
    my $self = shift;
    $self->socket->recv( my $response, $MAX_DATA_READ );

    if ( !defined $response ) {
        Net::LCDproc::Error->throw("No response from lcdproc: $!");
    }

    chomp $response;
    $log->debug("Received '$response'") if $log->is_debug;

    return $response;
}

sub _handle_response {
    my $self = shift;

    my $response_str = $self->recv_response;
    my $matched;
    my @args;
    foreach my $msg ( keys %{ $self->responses } ) {
        if ( @args = $response_str =~ $self->responses->{$msg} ) {
            $matched = $msg;
            last;
        }
    }

    if ( !$matched ) {
        say "Invalid/Unknown response from server: '$response_str'";
        return;
    }

    given ($matched) {
        when (/error/) {
            $log->error( 'ERROR: ' . $args[0] );
            return;
        };
        when (/connect/) {
            return \@args;
        }
        when (/success/) {
            return 1;
        };
        default {

            # don't care about listen or ignore
            # so find something useful to return
            # FIXME: start caring! Then only update the server when
            # it is actually listening
            return $self->_handle_response;
        };
    };

}

1;
