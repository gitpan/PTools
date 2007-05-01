# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl PTools.t'

#########################

###use Test::More tests => 3;

use Test::More;
BEGIN { 
    eval "require Date::Format";
    if (! defined $INC{'Date/Format.pm'} ) {
       plan skip_all => "dependency/ies not met";
    }
    plan tests => 3;
}

BEGIN { use_ok('PTools::Date::Format', "date1") };              # 01

my $fmt = new PTools::Date::Format;
ok( defined $fmt, "Instantiation okay" );                       # 02

## Start with a known epoch number
## epoch: 1174593154    date: Thu, 22-Mar-2007 01:52:34 PM

my $time = 1174593154;
my $str  = $fmt->time2str("%A is day %u in week %U%n", $time);
is( $str, "Thursday is day 4 in week 11\n",  "Does '%u' directive work?");  # 03

# TODO: Add tests for other 'use' options (":orig", "time2str", etc.)
# I'm not sure that 'no PTools::Date::Format' will do the right thing.
#########################
