#!/usr/bin/env prove

use Test::More;

if ( !defined $ENV{LCDPROC_SERVER} ) {
    plan skip_all => 'Set LCDPROC_SERVER ńfor full tests';
} else {
    plan tests => 11;
}

use Net::LCDproc;
use Net::LCDproc::Screen;
use Net::LCDproc::Widget::Title;
use Net::LCDproc::Widget::String;

ok($lcdproc = Net::LCDproc->new( server => $ENV{LCDPROC_SERVER}, port=> $ENV{LCDPROC_PORT} ));
ok($lcdproc->init);

ok($screen = Net::LCDproc::Screen->new( id => "main" ));
ok($screen->set( 'name',      "Test Screen" ));
ok($screen->set( 'heartbeat', "off" ));
ok($lcdproc->add_screen($screen));

ok(my $title = Net::LCDproc::Widget::Title->new( id => "title" ));
ok($title->text('Net::LCDproc Widget Tests'));
ok($screen->add_widget($title));

ok (my $string = Net::LCDproc::Widget::String->new(id => "string", x => 1, y => 2, text => $0));
ok($screen->add_widget($clock));
