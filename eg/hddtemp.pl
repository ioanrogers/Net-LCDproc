#!/usr/bin/perl

use v5.10.0;

use strict;
use warnings;

use Net::LCDproc;
use Net::LCDproc::Screen;
use Net::LCDproc::Widget::Title;
use Net::LCDproc::Widget::String;

use IO::Socket::Telnet;

my $hddtemp_host     = 'localhost';
my $hddtemp_port     = '7634';
my @hdd_dev_prefixes = qw/ sd /;

my $lcdproc;
my $screen;

my %hdds;

sub get_hddtemp_output {
    my $socket = IO::Socket::Telnet->new(
        PeerAddr => $hddtemp_host,
        PeerPort => $hddtemp_port,
    );

    if ( !$socket ) {
        say "Couldn't connect to hddtemp at '$hddtemp_host:$hddtemp_port': $!";
        return;
    }

    $socket->recv( my $output, 4096 )
      or return;

    $socket->shutdown(2);

    return $output;
}

sub parse_hddtemp_output {
    my ($hddtemp_output) = @_;

    $hddtemp_output =~ s/^\|//;
    $hddtemp_output =~ s/\|$//;
    my @tmp = split( /\|\|/, $hddtemp_output );

    foreach my $hdd (@tmp) {
        my ( $dev, $model, $temp, $unit ) = split( /\|/, $hdd );

        $dev =~ s/\/dev\///;
        my $accepted = grep { $dev =~ /^$_/ } @hdd_dev_prefixes;

        if ($accepted) {
            $hdds{$dev} = "$temp $unit";
        }
    }
}

sub setup_lcdproc_screen {
    $lcdproc = Net::LCDproc->new();
    $lcdproc->init()
      or die "cannot connect: $!";

    $screen = Net::LCDproc::Screen->new( id => "main" );

    my $title = Net::LCDproc::Widget::Title->new( id => "title" );
    $title->text('HDDTemps');
    $lcdproc->add_screen($screen);

    $screen->set( 'name',      "Test Screen" );
    $screen->set( 'heartbeat', "off" );

    $screen->add_widget($title);

}

sub add_hdd_widgets {

    my %widgets;

    my $line = 1;
    foreach my $hdd ( sort keys %hdds ) {

        my $widget = Net::LCDproc::Widget::String->new(
            id   => "widget_$line",
            x    => 1,
            y    => $line + 1,
            text => "$hdd $hdds{$hdd}",
        );
        $widgets{$hdd} = $widget;
        $line++;
        $screen->add_widget($widget);
    }
    return \%widgets;
}

sub update_hdd_widgets {

    my $widgets = shift;
    foreach my $hdd ( keys %hdds ) {
        my $old_text = $widgets->{$hdd}->text;
        my $new_text = "$hdd $hdds{$hdd}";
        if ($old_text eq $new_text) {
            next;
        }
        $widgets->{$hdd}->text("$hdd $hdds{$hdd}");
    }
}

my $hddtemp = get_hddtemp_output();
parse_hddtemp_output($hddtemp);

setup_lcdproc_screen();
my $widgets = add_hdd_widgets();

while (1) {

    my $hddtemp = get_hddtemp_output();
    parse_hddtemp_output($hddtemp);

    update_hdd_widgets($widgets);
    $lcdproc->update();
    sleep(60);
}

