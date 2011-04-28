#!/usr/bin/env perl

use 5.010;

use strict;
use warnings;

use Net::LCDproc;
use Net::LCDproc::Screen;
use Net::LCDproc::Widget::Title;
use Net::LCDproc::Widget::String;
use Sys::Hostname;
use Log::Any::Adapter;
use Log::Dispatch;

my $lcdproc;
my $screen;

my $loglevel = 'info';
if ( defined $ARGV[0] ) {
    $loglevel = $ARGV[0];
}

my $log = Log::Dispatch->new(
    outputs => [
        [
            'Screen',
            min_level => $loglevel,
            newline   => 1,
        ],
    ]
);
Log::Any::Adapter->set( 'Dispatch', dispatcher => $log );

$lcdproc = Net::LCDproc->new;

$lcdproc->init;

$screen = Net::LCDproc::Screen->new( id => "main" );

my $title = Net::LCDproc::Widget::Title->new( id => "title" );
$title->text('Net::LCDproc');
$lcdproc->add_screen($screen);

$screen->set( 'name',      "Test Screen" );
$screen->set( 'heartbeat', "off" );

$screen->add_widget($title);

my $wdgt = Net::LCDproc::Widget::String->new(
    id   => "wdgt",
    x    => 1,
    y    => 2,
    text => hostname,
);

$screen->add_widget($wdgt);

while (1) {

    $lcdproc->update();
    sleep(1);
}
