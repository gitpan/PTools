# -*- Perl -*-
#
# File:  PTools/Time/Elapsed.pm
# Desc:  Create formatted string with elapsed time
# Note:  Based on "cvt_secs_print()" subroutine by Douglas B. Robinson.
# Date:  Mon Aug 20 10:31:36 2001
# Stat:  Production
#
# Synopsis:
#        use PTools::Time::Elapsed;
#        $et  = new PTools::Time::Elapsed;
#
#        $str = $et->convert( $elapsed_seconds );
#  or    $str = $et->convert( $starttime, $endtime );
#
#  The above can also be invoked using the original subroutine name.
#
#        $str = $et->cvt_secs_print( $elapsed_seconds );
#  or    $str = $et->cvt_secs_print( $starttime, $endtime );
#
#  Note:  All methods work as both object methods (shown above) and 
#         as class methods (shown here).
#
#        $str = PTools::Time::Elapsed->convert( $elapsed_seconds );
#  or    $str = PTools::Time::Elapsed->convert( $starttime, $endtime );
#
#  For all of the above, $str result might equal "1 hour, 51 seconds",
#  for example. In addition, methods exist to provide for both a more
#  "granular" result (in terms of the "most significant" element),
#  and also to provide the raw values for each of the elements.
#
#        $str = $et->granular( $elapsed_seconds );
#  or    $str = $et->granular( $starttime, $endtime );
#
#  Where $str result might equal "1.00 hrs", for example.
#
#
#        (@ary) = $et->convertArgs( $elapsed_seconds );
#  or    (@ary) = $et->convertArgs( $starttime, $endtime );
#
#  Where @ary = ($yrs,$days,$hrs,$mins,$secs) 
#    and @ary result might equal (0,0,1,0,51) for example.
#
#

package PTools::Time::Elapsed;
 use strict;

 my $PACK = __PACKAGE__;
 use vars qw( $VERSION @ISA );
 $VERSION = '0.06';
#@ISA     = qw( );


sub new { bless {}, ref($_[0])||$_[0] }

   *cvt_secs_print = \&convert;      # provide a subroutine alias

sub convert
{   my($class,$start,$end) = @_;

    # Note that this method will omit any intermediate elements 
    # that are equal to zero. For example, this could return  
    #   "1 hour, 51 seconds"
    #
    return 0 unless $start;

    my $time = ( $end ? int($end - $start) : int($start) );
    return 0 unless $time > 0;

    # Since months vary in length, go straight from days to years
    #
    my $str = "";
    ($time,$str) = $class->_cvt($time, 60,"second",$str);
    ($time,$str) = $class->_cvt($time, 60,"minute",$str);
    ($time,$str) = $class->_cvt($time, 24,"hour",  $str);
    ($time,$str) = $class->_cvt($time,365,"day",   $str);
    ($time,$str) = $class->_cvt($time,  0,"year",  $str);

    return $str;
}

sub granular
{   my($class,$start,$end) = @_;

    # Return a "more granular" result in terms of the most significant
    # non-zero element. For example, this could return  "1.00 hrs"
    #
    my($yrs,$days,$hrs,$mins,$secs) = $class->convertArgs($start,$end);

    $yrs   and return sprintf("%0.2f yrs",  $yrs  + ($days / 365) );
    $days  and return sprintf("%0.2f days", $days + ($hrs  /  24) );
    $hrs   and return sprintf("%0.2f hrs",  $hrs  + ($mins /  60) );
    $mins  and return sprintf("%0.2f mins", $mins + ($secs /  60) );
    $secs  and return sprintf(   "%d secs", $secs);
    return "0 secs";
}

sub days
{   my($class,$start,$end) = @_;

    # Return result in terms of the "number of days"
    # For example, this could return  "0.04 days"
    #
    my($yrs,$days,$hrs,$mins,$secs) = $class->convertArgs($start,$end);

    $days += ($yrs * 365);
    $days += ($hrs /  24);
    $days  = sprintf("%0.2f", $days);
    $days  = $class->addCommasToNumber( $days );
    $days .= " day";
    $days .= "s" unless $days eq "1.00 day";

    return $days;
}

sub hours
{   my($class,$start,$end) = @_;

    # Return result in terms of the "number of hours"
    # For example, this could return  "1.00 hour" 
    #
    my($yrs,$days,$hrs,$mins,$secs) = $class->convertArgs($start,$end);

    $hrs += ($yrs * 365 * 24);
    $hrs += ($days * 24);
    $hrs += ($mins / 60);
    $hrs  = sprintf("%0.2f", $hrs);
    $hrs  = $class->addCommasToNumber( $hrs );
    $hrs .= " hour";
    $hrs .= "s" unless $hrs eq "1.00 hour";

    return $hrs;
}

sub addCommasToNumber
{   my($class,$string,$forceDecimal) = @_;

    $string = reverse $string;
    $string =~ s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g;
    $string =~ s/^(\d)\./0$1./;       # remember, it's still reversed here ;-)
    $forceDecimal and $string = "00.".$string if $string !~ /\./;

    return scalar reverse $string;
}


sub convertArgs
{   my($class,$start,$end) = @_;

    #  Return the raw values for each of the elements. For example,
    #  this could return  (0,0,1,0,51)
    #
    return(0,0,0,0,0) unless $start;

    my $time = ( $end ? int($end - $start) : int($start) );
    return(0,0,0,0,0) unless $time > 0;

    my($secs,$mins,$hrs,$days,$yrs) = (0,0,0,0,0);

    ($time,$secs) = $class->_cvt($time, 60,"second","ArgOnly");
    ($time,$mins) = $class->_cvt($time, 60,"minute","ArgOnly");
    ($time,$hrs)  = $class->_cvt($time, 24,"hour",  "ArgOnly");
    ($time,$days) = $class->_cvt($time,365,"day",   "ArgOnly");
    $yrs          = $time;

    return($yrs,$days,$hrs,$mins,$secs);
}

sub _cvt
{   my($class,$time,$num,$type,$str) = @_;

    # Note: $time is decremented, $str is pre-pended
    #
    my $incr = 0;
    if ($num) {
    	$incr = $time % $num;       # get "increment" for current $type
    	$time = int($time / $num);  # decrement time
    	$time = 0 if $time < 0;
    } else {
    	$incr = $time;              # for "0,year" in convert method
    }
    return($time,$incr) if $str eq "ArgOnly";  # for convertArgs method
    return($time,$str) if ($incr == 0);        # to omit null elements

    my $tmp = sprintf "%d %s%s", $incr, $type, ($incr == 1) ? "" : "s";

    $str = ($str ? "$tmp, $str" : $tmp);       # prepend $str
    return($time,$str);
}
#_________________________
1; # Required by require()

__END__

=head1 NAME

PTools::Time::Elapsed - Create formatted string with elapsed time

=head1 VERSION

This document describes version 0.05, released Dec, 2003.

=head1 SYNOPSIS

         use PTools::Time::Elapsed;
         $et  = new PTools::Time::Elapsed;

         $str = $et->convert( $elapsed_seconds );
   or    $str = $et->convert( $starttime, $endtime );

         $str = $et->cvt_secs_print( $elapsed_seconds );
   or    $str = $et->cvt_secs_print( $starttime, $endtime );
 
         $str = $et->days( $elapsed_seconds );
   or    $str = $et->days( $starttime, $endtime );

         $str = $et->hours( $elapsed_seconds );
   or    $str = $et->hours( $starttime, $endtime );

         $str = $et->granular( $elapsed_seconds );
   or    $str = $et->granular( $starttime, $endtime );

         (@ary) = $et->convertArgs( $elapsed_seconds );
   or    (@ary) = $et->convertArgs( $starttime, $endtime );

=head1 DESCRIPTION

This module is based on the B<cvt_secs_print()> subroutine 
by Douglas B. Robinson.

=head2 Constructor

=over 4

=item new

A constructor method is provided for convenience. All methods work
equally well as class or object methods as shown below.

         $et  = new PTools::Time::Elapsed;

=back

=head2 Methods

=over 4

=item convert ( { ElapsedSeconds | StartTime, EndTime } )

The B<convert> method returns a human readable time string from a
given number of seconds.

         $str = $et->convert( $elapsed_seconds );
   or    $str = $et->convert( $starttime, $endtime );

The B<convert> method can also be invoked using the original subroutine name.

         $str = $et->cvt_secs_print( $elapsed_seconds );
   or    $str = $et->cvt_secs_print( $starttime, $endtime );

Note:  All methods work as both object methods (shown above) and 
as class methods (shown here).

         $str = PTools::Time::Elapsed->convert( $elapsed_seconds );
   or    $str = PTools::Time::Elapsed->convert( $starttime, $endtime );

For all of the above, B<$str> result might equal "1 hour, 51 seconds",
for example. 

=item days ( { ElapsedSeconds | StartTime, EndTime } )

The B<days> method exists to return the result in days
with any hours represented as a decimal value.

         $str = $et->days( $elapsed_seconds );
   or    $str = $et->days( $starttime, $endtime );

Where B<$str> result might equal "0.04 days", for example.

=item hours ( { ElapsedSeconds | StartTime, EndTime } )

The B<hours> method exists to return the result in hours
with any minutes represented as a decimal value.

         $str = $et->hours( $elapsed_seconds );
   or    $str = $et->hours( $starttime, $endtime );

Where B<$str> result might equal "1.00 hours", for example.

=item granular ( { ElapsedSeconds | StartTime, EndTime } )

The B<granular> method exists to provide for a more "granular" result
(in terms of the "most significant" element). 

         $str = $et->granular( $elapsed_seconds );
   or    $str = $et->granular( $starttime, $endtime );

Where B<$str> result might equal "1.00 hrs", for example.




=item convertArgs ( { ElapsedSeconds | StartTime, EndTime } )

The B<convertArgs> method provides the raw values for each of the elements.

         (@ary) = $et->convertArgs( $elapsed_seconds );
   or    (@ary) = $et->convertArgs( $starttime, $endtime );

Where B<@ary> params = ($yrs,$days,$hrs,$mins,$secs) 
and B<@ary> result might equal (0,0,1,0,51) for example.

=back

=head1 INHERITANCE

No classes currently inherit from this class.

=head1 SEE ALSO

=head1 AUTHOR

Chris Cobb [no dot spam at ccobb dot net]

=head1 COPYRIGHT

Copyright (c) 2002-2007 by Chris Cobb. All rights reserved.
This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut

