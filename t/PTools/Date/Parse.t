# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl PTools.t'

#########################

#### use Test::More tests => 4;

use Test::More;
BEGIN { 
    eval "require Date::Parse";
    if (! defined $INC{'Date/Parse.pm'} ) {
       plan skip_all => "dependency/ies not met";
    }
    plan tests => 4;
}

BEGIN { use_ok('PTools::Date::Parse') };               # 01

my $dp = "PTools::Date::Parse";
ok( defined $dp, "Instantiation okay" );               # 02

my $result;
$result = $dp->str2time( "Mon, 19-Mar-2007 03:04:59 PM", "CST" );
is( $result, 1174338299, "str2time parsing okay" );    #03

my(@args) = $dp->strptime( "Mon, 19-Mar-2007 03:04:59 PM", "CST" );
$result = join(" ", @args);
is( $result, "59 04 15 19 2 107 -21600", "strptime parsing okay" );    #04

#########################
