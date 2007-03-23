#!/opt/perl/bin/perl -w
#
# File:  datefmt.pl
# Desc:  Demo of date formatting/string manipulation
# Date:  Mon Oct 30 11:59:58 2000
# Stat:  Prototype
# Note:  Uses Graham Barr's Date::Format and Date::Parse modules. 
#        Should handle any date format as input, including epoch.
#
# Examples:
#        datefmt.pl                 # print current date and epoch
#        datefmt.pl "<dateString>"  # convert dateString to epoch
#        datefmt.pl <epoch>         # convert epoch to dateString
#

use PTools::Date::Format;    # $string = $df->time2str("%c", $time);
use PTools::Date::Parse;     # $epoch  = $df->str2time($dateString);

my($df, $dp) = ( "PTools::Date::Format", "PTools::Date::Parse" );

my($base) = ( $0 =~ m#^(?:.*/)?(.*)# );
my $Usage = "
 Usage:
    $base [-R]               # print current date and epoch
    $base [-R] <epoch>       # convert epoch to dateString
    $base '<dateString>'     # convert dateString to epoch
\n";

my $rom = ( $ARGV[0] and $ARGV[0] eq "-R" ? shift @ARGV : "" );
my $str = $ARGV[0] || time;
$str eq "-h" and die $Usage;

my $fmt = "%a, %d-%b-%Y %I:%M:%S %p";  # Wed, 22-Nov-2000 09:05:39 pm
 # $fmt = "%C";                        # Wed Nov 22 21:05:57 2000
 # $fmt = "%d-%b-%Y.%I:%M:%S";         # 22-Nov-2000.09:05:39
my $fmtR= "%a, %Od-%b-%OY";            # XXII-Nov-MM (Roman Numerals ;-)

if ($str =~ /^\d*$/) {
    $rom and $fmt = $fmtR;
    my $result = $df->time2str($fmt, $str) || die $Usage;
    print "\n epoch: $str    date: $result\n\n";

} else {
    my $result = $dp->str2time($str) || die $Usage;
    print "\n date: $str    epoch: $result\n\n";
}
