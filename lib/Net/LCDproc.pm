package Net::LCDproc;

# ABSTRACT: LCDproc client library

use 5.0100;
use Moose;
use Net::LCDproc::Net;
with 'Throwable';

use YAML::XS;

use Net::LCDproc::Error;

use namespace::autoclean;

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

sub init {
    my $self = shift;
    my $conn = Net::LCDproc::Net->new();
    $self->_send_hello($conn);
    $self->_conn($conn);
}

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

sub _send_hello {
    my ($self, $con) = @_;

    $con->_send_cmd('hello');
    my $response = $con->_recv_response();

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

