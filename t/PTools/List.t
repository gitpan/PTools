# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl PTools.t'

#########################

use Test::More tests => 9;

BEGIN { use_ok('PTools::List') };    # 01

my $notes = new PTools::List("errs", "first","second");
ok( defined $notes, "Instantiation okay" );                     # 02
is( $notes->occurred('errs'), 2, "How many errs occured?");     # 03

my(@expected) = ("first","second");
my(@actual) = $notes->return('errs');
is( @expected, @actual, "Show me the 'errs'");                  # 04

#-----------------------------
my $tmp = new PTools::List("warn", "one");
is( $tmp->occurred('warn'), 1, "How many warn occured?");       # 05

$tmp->add('warn', "two");
$notes->add( $tmp );
is( $notes->occurred('warn'), 2, "Can we combine lists?");      # 06
#-----------------------------

(@expected) = ("errs","warn");
my(@occurred) = $notes->occurred();
is( @occurred, @expected, "How many lists do we have?");        # 07


my $expected = "errs:\n   first\n   second\n\nwarn:\n   one\n   two\n";
my $format = $notes->format();
is ($format, $expected, "Does format() work?");                 # 08

$expected = "errs:  2\nwarn:  2\n";
my $summary = $notes->summary();
is ($summary, $expected, "Does summary() work?");               # 09

#########################
