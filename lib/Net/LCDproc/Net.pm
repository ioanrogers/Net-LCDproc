package Net::LCDproc::Net;

use v5.10.0;
use Moose;
use Net::LCDproc::Error;
use IO::Socket::INET;
use YAML::XS;

sub DEMOLISH {
    my $self = shift;
    say "Shutting down socket";
    $self->socket->shutdown('2');
}

has server => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
    default  => 'localhost',
);

has port => (
    is       => 'rw',
    isa      => 'Int',
    required => 1,
    default  => 13666,
);

has socket => (
    is         => 'ro',
    isa        => 'IO::Socket::INET',
    required   => 1,
    builder    => '_connect',
    lazy       => 1,
);

sub _connect {
    my $self = shift;

    my $socket = IO::Socket::INET->new(
        PeerAddr => $self->server,
        PeerPort => $self->port,
        ReuseAddr => 1,
#        Timeout => '5',
    );

    if ( !$socket ) {
        Net::LCDproc::Error->throw( sprintf "Couldn't connect to lcdproc at '%s:%s': %s",
            $self->server, $self->port, $! );
    }

    return $socket;

}

sub _send_cmd {
    my ($self, $cmd) = @_;

    say "Sending '$cmd'";

    my $ret = $self->socket->send($cmd);
    if (!defined $ret) {
        die "Error sending $cmd";
    }
    
    return;
}

sub _recv_response {
    my $self = shift;
    $self->socket->recv( my $response, 4096 );

    if ( !defined $response ) {
        Net::LCDproc::Error->throw("No reponse from lcdproc: $!");
    }
    
    chomp $response;
    say "Received '$response'";
    
    #say Dump($self->socket);
    #say "Returning";
    return $response;
}


1;


