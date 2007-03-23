# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl PTools.t'

#########################

use Test::More tests => 3;

BEGIN { use_ok('PTools::WordWrap') };                 # 01

my $unformat = "some not-so-long line of text";
my $formated = PTools::WordWrap->parse( 20, $unformat );
my $expected = "some not-so-long\nline of text";
ok( $formated eq $expected, "Wrapped okay" );         # 02

# Feed it through again... should be no change

$formated = PTools::WordWrap->parse( 20, $formated );
ok( $formated eq $expected, "Wrapped okay" );         # 03

#########################
