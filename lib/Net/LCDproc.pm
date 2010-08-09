package Net::LCDproc;

# ABSTRACT: LCDproc client library

use 5.0100;
use Moose;
use Net::LCDproc::Error;
use Net::LCDproc::Net;
use YAML::XS;

use namespace::autoclean;

has server => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
    default  => 'localhost',
);

has port => (
    is       => 'ro',
    isa      => 'Int',
    required => 1,
    default  => 13666,
);

has width => (
    is  => 'rw',
    isa => 'Int',
);

has height => (
    is  => 'rw',
    isa => 'Int',
);

has cell_width => (
    is  => 'rw',
    isa => 'Int',
);

has cell_height => (
    is  => 'rw',
    isa => 'Int',
);

has screens => (
    is      => 'rw',
    isa     => 'ArrayRef[Net::LCDproc::Screen]',
    default => sub { [] },
    lazy    => 1,
);

has _conn => (
    is      => 'rw',
    isa     => 'Net::LCDproc::Net',
);

sub add_screen {
    my ( $self, $screen ) = @_;
    $screen->_conn($self->_conn);
    push @{ $self->screens }, $screen;
    
    return $screen;
}

sub remove_screen {
    my ( $self, $screen ) = @_;
    my $i = 0;
    foreach my $s ( @{ $self->screens } ) {
        if ( $s == $screen ) {
            say "Removing $s";
            splice( @{ $self->screens }, $i, 1 );
            return 1;
        }
        $i++;
    }
    say "Failed to remove screen";
    return -1;

}

# updates the screen on the server
sub update {
    my $self = shift;
    foreach my $s ( @{ $self->screens } ) {
        $s->update();
    }
    
}

sub init {
    my $self = shift;
    my $conn = Net::LCDproc::Net->new(server => $self->server, port => $self->port);
    $conn->_connect;
    $self->_conn($conn);
    $self->_send_hello;
}

sub _send_hello {
    my $self = shift;

    $self->_conn->_send_cmd('hello');
    my $response = $self->_conn->_recv_response();

    if ( $response =~
        m/^connect LCDproc \S+ protocol (\S+) lcd wid (\d+) hgt (\d+) cellwid (\d+) cellhgt (\d+)$/
      )
    {

        # TODO check protocol version

        $self->width($2);
        $self->height($3);
        $self->cell_width($4);
        $self->cell_height($5);
    } else {
        die "Invalid reponse from server: '$response'";
    }
    
    return;
}

no Moose;

__PACKAGE__->meta->make_immutable;

1;

