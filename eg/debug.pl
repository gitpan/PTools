#!/opt/perl/bin/perl
#
# File:  debug.pl
# Desc:  Demo of using the Debug class
#
use 5.006;
use strict;
use warnings;
use PTools::Global;        # Application Global variables
use PTools::Debug;

my $debug       = new PTools::Debug( @ARGV );
my $debugLevel  = $debug->getLevel;    # passed from cmd-line
my $indentLevel = $debug->getIndent ||0;

print "\n";
if (defined $debugLevel) {
     print "Debug level  = '$debugLevel'\n";
} else {
     print "Debug level  = <undefined>\n\n";
     print "Usage: $0  [ verboseLevel ] [, indentLevel ]\n";
     print "\n";
     print "Note that a 'verboseLevel' of [ 0 - 6 ] is good for a demo,\n";
     print "and that an 'indentLevel' of [ nul - 4 ] is also good demo.\n";
     print "\n";
}

if ($debug->isSet) {
    print "Indent level = '$indentLevel'\n";
    print "\n";
}

$debug->if   ( undef, "Level undef"  );
$debug->and  (     0, "Level 0"      );
$debug->prn  (     1, "Level 1"      );
$debug->print(     2, "Level 2"      );
$debug->print(     2, "Level 2-3", 3 );
$debug->warn (     3, "Level 3"      );
$debug->warn (     3, "Level 3-4", 4 );
$debug->if   (     4, "Level 4"      );

if ($debug->isSet) {
    if (! $debug->getIndent) {
       $indentLevel = 4;
       $debug->setIndent( $indentLevel );
       print "\nIndent level = '$indentLevel'\n";
    }
    print "\n";
}

  is $debug( undef, "Level u-*",   2 );
  is $debug(     0, "Level 0-*",   2 );
  is $debug(     1, "Level 1-3",   3 );
  at $debug(     2, "Level 2"      );
  at $debug(     2, "Level 2-2",   2 );
  at $debug(     2, "Level 2-3",   3 );
  at $debug(     3, "Level 3"      );
 chk $debug(     3, "Level 3-4",   4 );
test $debug(     3, "Level 3-5",   5 );

print "\n" if $debug->isSet;
