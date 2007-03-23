# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl PTools.t'

#########################

use Test::More tests => 19;

BEGIN { use_ok('PTools::String') };                   # 01

my $str = new PTools::String();
ok( defined $str, "String instantiated" );            # 02

my $result;
#------------------------------------------
# addCommasToNumber

$result = $str->addCommasToNumber( 1234567 );
is( $result, "1,234,567", "Simple comma addition" );  # 03

$result = $str->addCommasToNumber( "Total cost: 12345.67" );
is( $result, "Total cost: 12,345.67", "Commas, decimal, w/text" );  # 04

#------------------------------------------
# centerInBuffer

$result = $str->centerInBuffer("Some Text", 30);
is( $result, "          Some Text           ",
              "Center some text" );                   # 05

#------------------------------------------
# justifyRight

$result = $str->justifyRight("Some Text", 30);
is( $result, "                     Some Text",
              "Right-justify text" );                 # 06

#------------------------------------------
# justifyListRight (handles commas, too)

$str  = "PTools::String";
my($total,$avail,$used) = (1037320, 172, 17628504);
my $nums = [ "$total KB", "$avail KB", "$used KB" ];

 # "1037320 KB",      # " 1,037,320 KB",  
 # "172 KB",          # "       172 KB",      
 # "17628504 KB"      # "17,628,504 KB"  

# Warn: this modifies the '$nums' listRef... no $result here!
#
$str->justifyListRight( $nums, "addCommas" );
$result = join("\n", @$nums);

is( $result, " 1,037,320 KB\n       172 KB\n17,628,504 KB",
               "Commas to a list of nums w/text");               # 07

#------------------------------------------
# initalCaps

$result = $str->initialCaps("john q. public");
is( $result, "John Q. Public", "Initial Upshift Okay" );   # 08

#------------------------------------------
# stripExtraWhiteSpace
# stripLeftWhiteSpace
# stripRightWhiteSpace

$result = $str->stripExtraWhiteSpace("  Some text    ");
is( $result, "Some text", "Whitespace strip okay" );   # 09

$result = $str->stripLeftWhiteSpace("  Some text    ");
is( $result, "Some text    ", "Left space strip okay" );   # 10

$result = $str->stripRightWhiteSpace("  Some text    ");
is( $result, "  Some text", "Right space strip okay" );   # 11

#------------------------------------------
# zero

$result = $str->zero( undef, undef );
is( $result, undef, "Result is 'undef'" );                # 12

$result = $str->zero( 0 );
ok( (length $result and ! $result), "Result is zero" );   # 13

$result = $str->zero( 1 );
is( $result, 1, "Result is one" );                        # 14

$result = $str->zero( "Text string" );
is( $result, "Text string", "Result is okay" );           # 15

#------------------------------------------
# plural

$result = $str->plural( 0, "Warning", "s" );
is( $result, "Warnings", "Result is okay" );             # 16

$result = $str->plural( 1, "Warning", "s" );
is( $result, "Warning", "Result is okay" );              # 17

$result = $str->plural( 0, "Descrepenc", "ies", "y" );
is( $result, "Descrepencies", "Result is okay" );        # 18

$result = $str->plural( 1, "Descrepenc", "ies", "y" );
is( $result, "Descrepency", "Result is okay" );          # 19

#------------------------------------------
# prompt
# FIX: method reads from STDIN...

#------------------------------------------
# untaint / detaint

#------------------------------------------
# isTainted


#########################
