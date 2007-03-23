#!/opt/perl/bin/perl
#
# File:  counter.pl
# Desc:  Demo of using the PTools::Counter class
#
# (See notes below on 'accumulated' time vs 'elapsed' time.)
#
use 5.006;
use strict;
use warnings;
use PTools::Counter;

my $ctr = new PTools::Counter;

print "---------------------\n";
print "result() example 1:\n";
print "---------------------\n";

$ctr->init('warn', "    Warnings: ");
$ctr->incr('warn');

$ctr->init('errs', "      Errors: ");
$ctr->incr('errs');
$ctr->incr('warn');   # add another warning

print $ctr->result('warn') ."\n";
print $ctr->result('errs') ."\n";

print "\n";
print "---------------------\n";
print "format() example 1:  Add start/end times\n";
print "---------------------\n";

# Note: Normally you just call "$ctr->incr('warn')"
# without any argument... here we want to show how
# the numbers are all formatted right-justified,
# and adding an arg is easier than using a loop.

$ctr->incr('warn', 10);
my $time = time();   ## '1174285168';

$ctr->start( "  Start Time: ", $time );
$ctr->end  ( "    End Time: ", $time + 100 );
print $ctr->format();

print "\n";
print "---------------------\n";
print "format() example 2:  Add elapsed time\n";
print "---------------------\n";

$ctr->incr('warn', 210);
##$ENV{TZ} = "PST8PDT";

$ctr->elapsed( "Elapsed Time: ", $time + 100 );
print $ctr->format();

print "\n";
print "---------------------\n";
print "format() example 3:  Add 'accumulated' time, and alter time format\n";
print "---------------------\n";

# Note:  'Accumulated' time is different from 'Elapsed'
# time in situations where multi-processing occurs. If
# a control process monitors multiple child processes, 
# each running on a separate CPU, for example, these
# times will be very different--and will highlight the
# benefit of using a multi-processing model vs. using a
# single process script. 
#
# (See "POE::Component::NWay", coming soon to a CPAN near 
# you. Using this POE component, in one example on an 8-CPU 
# machine, saw an 'accumulated' time of 75 hours with an 
# 'elapsed' time of just under 10 hours. Almost 8x faster
# then running a single process to accomplish the task!)

$ctr->incr('warn', 3020);
$ctr->incr('errs', 35);

$ctr->cumulative( "  Accum Time: ", 700 );
$ctr->tmFormat( "%c" );                        # 12/21/05 09:05:39

print $ctr->format();
print "\n";
print "(See notes in this example script on using 'accumulated' time.)\n";
print "\n";

print "---------------------\n";
print "format() example 4:  Add header and footer to output, new time format\n";
print "---------------------\n";
print "\n";

my($header,$footer) = ("Results of Tasks","End of Tasks.");
$ctr->head( "$header\n". "-" x length($header) );
$ctr->foot( "-" x length($header) . "\n$footer\n");
$ctr->tmFormat( "%a, %d-%b-%Y %I:%M:%S %p" );  # Wed, 21-Dec-2005 09:05:39 pm

print $ctr->format();
print "\n";

__END__

# Some time format examples suported by the 'PTools::Date::Format' class
#
# $ctr->tmFormat( "%c" );                        # 12/21/05 09:05:39
# $ctr->tmFormat( "%a, %d-%b-%Y %I:%M:%S %p" );  # Wed, 21-Dec-2005 09:05:39 pm
# $ctr->tmFormat( "%d-%b-%Y %H:%M:%S" );         # 21-Dec-2005 21:05:39
# $ctr->tmFormat( "%Y%m%d %H:%M:%S" );           # 20051221 21:05:39
#

