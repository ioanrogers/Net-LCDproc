use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::NoTabsTests 0.06

use Test::More 0.88;
use Test::NoTabs;

my @files = (
    'lib/Net/LCDproc.pm',
    'lib/Net/LCDproc/Error.pm',
    'lib/Net/LCDproc/Role/Widget.pm',
    'lib/Net/LCDproc/Screen.pm',
    'lib/Net/LCDproc/Widget.pm',
    'lib/Net/LCDproc/Widget/Frame.pm',
    'lib/Net/LCDproc/Widget/HBar.pm',
    'lib/Net/LCDproc/Widget/Icon.pm',
    'lib/Net/LCDproc/Widget/Num.pm',
    'lib/Net/LCDproc/Widget/Scroller.pm',
    'lib/Net/LCDproc/Widget/String.pm',
    'lib/Net/LCDproc/Widget/Title.pm',
    'lib/Net/LCDproc/Widget/VBar.pm'
);

notabs_ok($_) foreach @files;
done_testing;
