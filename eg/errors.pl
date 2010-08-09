#!/usr/bin/env perl

use 5.010;

use strict;
use warnings;

use Net::LCDproc;
use Net::LCDproc::Screen;
use Net::LCDproc::Widget::Title;
use Net::LCDproc::Widget::String;

use Sys::Hostname;
use YAML::XS;
use Try::Tiny;

my $lcdproc;
my $screen;

$lcdproc = Net::LCDproc->new( server => 'localhost', port => 1234 );

try {    
    $lcdproc->init;
}
catch {
    say "cannot connect: ". $_->message;
    say $_->dump;
    die $_->short_msg;
};

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
