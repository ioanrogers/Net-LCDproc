package Net::LCDproc::Net;

use v5.10.0;
use Moose;
use Net::LCDproc::Error;

use IO::Socket::INET;
use YAML::XS;

sub DEMOLISH {
    my $self = shift;
    if ( $self->has_socket && defined $self->socket ) {
        say "Shutting down socket";
        $self->socket->shutdown('2');
    }
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

sub _connect {
    my $self = shift;

    my $socket = IO::Socket::INET->new(
        PeerAddr  => $self->server,
        PeerPort  => $self->port,
        ReuseAddr => 1,
    );

    if ( !defined $socket ) {

        Net::LCDproc::Error->throw(
            message    => sprintf ("Couldn't connect to lcdproc server at '%s:%s': %s",
                                    $self->server, $self->port, $!),
            class_name => __PACKAGE__,
            object     => $self, 
        );
    }

    $self->socket($socket);

}

sub _send_cmd {
    my ( $self, $cmd ) = @_;

    say "Sending '$cmd'";

    my $ret = $self->socket->send($cmd);
    if ( !defined $ret ) {
        Net::LCDproc::Error->throw("Error sending $cmd: $!");
    }

    return;
}

sub _recv_response {
    my $self = shift;
    $self->socket->recv( my $response, 4096 );

    if ( !defined $response ) {
        Net::LCDproc::Error->throw("No response from lcdproc: $!");
    }

    chomp $response;
    say "Received '$response'";

    return $response;
}

1;
