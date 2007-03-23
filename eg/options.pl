#!/opt/perl/bin/perl -w
#
# File:  options.pl
# Desc:  Demo of using the PTools::Options and PTools::Debug classes
#
use 5.006;
use strict;
use warnings;
use PTools::Options;
use PTools::Debug;

#-----------------------------------------------------------------------
# First, do a listle setup. See the Getopt::Long man page for @optArgs

 my($basename)= ( $0 =~ m#^(?:.*/)?(.*)# );

 my @optArgs  = qw( help|h verbose|v+ Debug|D:i );     # See Getopt::Long

 my $usage    = "Usage: $basename [-h] [-v[v...]] [-D [n]]";

#-----------------------------------------------------------------------
# Parse command line options and arguments; abort if error(s) occurred

 my $opts = new PTools::Options( $usage, @optArgs );

 $opts->abortOnError;

#-----------------------------------------------------------------------
# Display the results. Note that the first two methods used below,
# "usage" and "optArgs", are not very interesting here as we already
# know what the values are. However, these are useful when there are
# multiple modules in an application that may want to know the values.

#   $usage   = $opts->usage;        # get value passed to 'new' method, above
#my $optArgs = $opts->optArgs;      # get args passed to 'new' method, above

 my $optRef  = $opts->opts;         # get user entered cmd-line options 
 my $argRef  = $opts->args;         # get user entered cmd-line arguments
 my @args    = ( $argRef ? @{ $argRef } : "" );

 if ($opts->help) {                 # Note: "automatic accessor" method
    print "\n $usage\n\n";
    exit(0);
 } 

 print "\nScript Settings\n";
 print "             usage = $usage\n";          # The orig usage value
 print "           optArgs = @optArgs\n";        # The Getopt::Long args

 print "\nCommand-line Parameters\n";
 print "           options = @{ $optRef }\n";    # Options that were used
 print "         arguments = @args\n";           # Arguments entered

 # Notice the following "automatic accessor" methods here. These work
 # because the "$opts" object just happens to have attributes named
 # "verbose" and "Debug" (and "help" as used above). But only because 
 # we defined them in the list of valid options when instantiating the
 # "$opts" object, above, and only when a the options are actually used.

 my $debugLevel   = $opts->Debug;                # Examples of "automatic
 my $verboseLevel = $opts->verbose;              # accessor" methods


 print "       debug level = $debugLevel\n"    if defined $debugLevel;
 print "     verbose level = $verboseLevel\n"  if defined $verboseLevel;
 print "\n";

#-----------------------------------------------------------------------
# The following is added to show how simple the Debug class
# is to use in combination with the Options class.

 my $debug = new PTools::Debug( $opts->Debug );

 if ($debug->isSet) {
     print "The following is added to show how simple the Debug class\n";
     print "is to use in combination with the Options class.\n\n";
 } else {
     print "Note that a 'Debug' level of [ 0 - 5 ] is good for a demo.\n";
 }

 # Note: All of the following methods are aliases; they are identical.

 $debug->if   ( undef, "Message at level undef"  );   # but only if -D used
 $debug->and  (     0, "Message at level 0"      );
 $debug->prn  (     1, "Message at level 1"      );
 $debug->print(     2, "Message at level 2"      );
 $debug->print(     2, "Message at level 2-3", 3 );   # Note: min 2, max 3
 $debug->warn (     3, "Message at level 3"      );
 $debug->warn (     3, "Message at level 3-4", 4 );   # Note: min 3, max 4
 $debug->if   (     4, "Message at level 4"      );

 print "\n";

#-----------------------------------------------------------------------
#print $opts->dump;        # This can be useful when debuging.
#print $debug->dump;       # This one's not very useful.

 exit(0);
