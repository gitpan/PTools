#!/opt/perl/bin/perl -w
#
# File:  timeelapse.pl
# Desc:  Demo of elapsed time calculations
#
# Examples:
#        timeelapse.pl  # reports elapsed time since the "epoch"
#        timeelapse.pl  <elapsed-seconds> 
#        timeelapse.pl  <starting-epoch> <ending-epoch> 
#
use strict;
use PTools::Time::Elapsed;

my($base) = ( $0 =~ m#^(?:.*/)?(.*)# );
my $Usage = "
 Usage: $base -h
        $base [-{d|H|g|r}] <elapsed-seconds>
        $base [-{d|H|g|r}] <starting-epoch> <ending-epoch>
\n";

 my($granular,$raw,$days,$hours) = ("","","","");
 if ($ARGV[0] and $ARGV[0] eq "-h") {
    die $Usage;
 } elsif ($ARGV[0] and $ARGV[0] eq "-g") {
    $granular = shift;
 } elsif ($ARGV[0] and $ARGV[0] eq "-r") {
    $raw = shift;
 } elsif ($ARGV[0] and $ARGV[0] eq "-d") {
    $days = shift;
 } elsif ($ARGV[0] and $ARGV[0] eq "-H") {
    $hours = shift;
 }
 my($start,$end) = @ARGV;
 $start ||= time;
 $end   ||= "";

 $start and (($start =~ /^\d*$/) or die $Usage);
 $end   and (($end   =~ /^\d*$/) or die $Usage);

 my $et = new PTools::Time::Elapsed;

 if ($granular) {
    print $et->granular($start, $end) ."\n";

 } elsif ($raw) {
    my($yrs,$days,$hrs,$mins,$secs) = $et->convertArgs($start,$end);
    print "($yrs,$days,$hrs,$mins,$secs)\n";

 } elsif ($days) {
    print $et->days($start, $end) ."\n";

 } elsif ($hours) {
    print $et->hours($start, $end) ."\n";

 } else {
   # These two methods are equivalent
   #
   #print $et->convert($start, $end) ."\n";

    print $et->cvt_secs_print($start, $end) ."\n";
 }
 exit(0);
