# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl PTools.t'

#########################

use Test::More tests => 8;

BEGIN { use_ok('PTools::Time::Elapsed') };           # 01

# Test 'object' methods ---------------------------------

my $et = new PTools::Time::Elapsed;
ok( defined $et, "Instantiation okay" );             # 02

my $str;
$str = $et->convert( 75 );
is( $str, "1 minute, 15 seconds", "Is convert( secs ) working?");      # 03

$str = $et->convert( 75, 150 );
is( $str, "1 minute, 15 seconds", "Is convert( start,end ) working?"); # 04

$str = $et->granular( 75 );
is( $str, "1.25 mins", "Is granular( secs ) working?");                # 05

$str = $et->granular( 75, 150 );
is( $str, "1.25 mins", "Is granular( start,end ) working?");           # 06

my(@expected) = (0,0,0,1,15);
my(@actual)   = $et->convertArgs( 75 );
is( @actual, @expected, "Is convertArgs( secs ) working?");            # 07

(@actual) = $et->convertArgs( 75, 150 );
is( @actual, @expected, "Is convertArgs( start,end ) working?");       # 08


# TODO: These should all work identically as 'class' methods, too.
#########################
