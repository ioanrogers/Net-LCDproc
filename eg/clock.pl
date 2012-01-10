#!env perl

use v5.10;

use strict;
use warnings;

use DateTime;
use Log::Any::Adapter;
use Log::Dispatch;

use Net::LCDproc;
use Net::LCDproc::Screen;
use Net::LCDproc::Widget::Title;
use Net::LCDproc::Widget::String;

my $lcdproc;
my $screen;
my $loglevel = 'info';

if ( defined $ARGV[0] ) {
    $loglevel = $ARGV[0];
}

sub start_logging {

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

    return $log;
}

sub setup_lcdproc_screen {
    $lcdproc = Net::LCDproc->new;

    $screen = Net::LCDproc::Screen->new( id => "main" );

    my $title = Net::LCDproc::Widget::Title->new( id => "title" );
    $title->text('Net::LCDproc');
    $lcdproc->add_screen($screen);

    $screen->set( 'name',      "Test Screen" );
    $screen->set( 'heartbeat', "off" );

    $screen->add_widget($title);

}

sub get_date_time {
    my $dt = DateTime->now;
    my $date_str = sprintf "%s %d %s %d", $dt->day_abbr, $dt->day, $dt->month_abbr, $dt->year;
    return ( $dt->hms, $date_str );
}

sub add_widgets {

    my %widgets;

    my ( $time_str, $date_str ) = get_date_time();

    my $clock = Net::LCDproc::Widget::String->new(
        id   => "clock",
        x    => 1,
        y    => 2,
        text => $time_str,
    );

    $widgets{clock} = $clock;
    $screen->add_widget($clock);

    my $date = Net::LCDproc::Widget::String->new(
        id   => "date",
        x    => 1,
        y    => 3,
        text => $date_str,
    );

    $widgets{date} = $date;
    $screen->add_widget($date);

    return \%widgets;
}

setup_lcdproc_screen;
start_logging;
my $widgets = add_widgets;

while (1) {

    my ( $time_str, $date_str ) = get_date_time;

    $widgets->{clock}->text($time_str);

    # if day hasn't changed, don't update
    if ( $widgets->{date}->text ne $date_str ) {
        $widgets->{date}->text($date_str);
    }

    $lcdproc->update;
    sleep(1);
}
