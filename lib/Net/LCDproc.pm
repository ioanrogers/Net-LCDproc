package Net::LCDproc;

# ABSTRACT: LCDproc client library

use 5.0100;
use Moose;
use Net::LCDproc::Error;
use Net::LCDproc::Net;
use Log::Any qw($log);
use namespace::autoclean;

use constant PROTOCOL_VERSION => 0.3;

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
    is  => 'rw',
    isa => 'Net::LCDproc::Net',
);

sub add_screen {
    my ( $self, $screen ) = @_;
    $screen->_conn( $self->_conn );
    push @{ $self->screens }, $screen;

    return $screen;
}

sub remove_screen {
    my ( $self, $screen ) = @_;
    my $i = 0;
    foreach my $s ( @{ $self->screens } ) {
        if ( $s == $screen ) {
            $log->debug("Removing $s") if $log->is_debug;
            splice @{ $self->screens }, $i, 1;
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
    foreach my $s ( @{ $self->screens } ) {
        $s->update();
    }
    return 1;
}

sub init {
    my $self = shift;
    my $conn = Net::LCDproc::Net->new( server => $self->server, port => $self->port );
    $conn->connect_to_lcdproc;
    $self->_conn($conn);
    $self->_send_hello;

    return 1;
}

sub _send_hello {
    my $self = shift;

    my $response = $self->_conn->send_cmd('hello');

    if ( !ref $response eq 'ARRAY' ) {
        Net::LCDproc::Error->throw("Failed to read connect string");
    }
    my $proto = $response->[1];

    $log->infof( 'Connected to LCDproc version %s, proto %s', $response->[0], $proto );
    if ( $proto != PROTOCOL_VERSION ) {
        Net::LCDproc::Error->throwf( "Unsupported protocol version. Available: %s Supported: %s",
            $proto, PROTOCOL_VERSION );
    }
    $self->width( $response->[2] );
    $self->height( $response->[3] );
    $self->cell_width( $response->[4] );
    $self->cell_height( $response->[5] );

    return 1;
}

no Moose;

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

B<Net::LCDproc>

=head1 DESCRIPTION

Client library to interact with L<LCDproc|http://lcdproc.sourceforge.net/>

=head1 SYNOPSIS

    $lcdproc = Net::LCDproc->new();
    $lcdproc->init;
    $screen = Net::LCDproc::Screen->new( id => "main" );

    my $title = Net::LCDproc::Widget::Title->new( id => "title" );
    $title->text('My Screen Title');
    $lcdproc->add_screen($screen);

    $screen->set( 'name',      "Test Screen" );
    $screen->set( 'heartbeat', "off" );

    $screen->add_widget($title);

    my $wdgt = Net::LCDproc::Widget::String->new(
        id   => "wdgt",
        x    => 1,
        y    => 2,
        text => "Some Text",
    );

    $screen->add_widget($wdgt);

    while (1) {
        # update your widgets..
        $lcdproc->update();
        sleep(1);
    }

=head1 INSTALLATION

    git clone http://github.com/ioanrogers/net-lcdproc.git
    cd net-lcdproc
    dzil install

=head1 LICENSE

This software is Copyright (c) 2010 by Ioan Rogers.

This is free software, licensed under:

  The Artistic License 2.0

=cut

