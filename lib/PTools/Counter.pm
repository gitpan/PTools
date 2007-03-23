# -*- Perl -*-
#
# File:  PTools/Counter.pm
# Desc:  Maintain counters and generate syntactically correct results
# Stat:  Production
#
# Synopsis:
#
#        use PTools::Counter;
#        my $count = new PTools::Counter;
#
#   Initialize some counters
#
#        $counter->init("error", "    Errors: ");
#        $counter->init("warn",  "  Warnings: ");
#
#   Increment a counter
#
#        $counter->incr("warn");
#
#
#   Display some results
#
#        # The following will generate output that resembles:
#        #   Warnings:  1
#        #     Errors:  0
#
#        foreach my $counterName ("warn","error") {
#            print $counter->result( $counterName ) ."\n";
#        }
#
#        # The following will generate output that resembles:
#        #     Errors: 0   Warnings: 1
#
#        print $counter->result('error'), " ", $counter->result('warn'), "\n";
#
#
#        # Note: using "dot" to concatenate strings invokes
#        # method in "scalar" context, while using a comma
#        # to concatenate invokes method in "array" context.
#        # There may be some differences in the results.
#
#
#   Initialize counters such that results are syntactically correct
#
#        $counter->init("error", "Descrepenc","ies","y");
#        $counter->init("warn",  "Warning","s");
#
#
#   Obtain results that are suitable for additional formatting
#
#        # The following will generate output that resembles:
#        #    Found 0 Descrepencies
#        #    Found 1 Warning
#
#        foreach my $counterName ("error","warn") {
#            ($text,$value) = $counter->result( $counterName );
#            print "Found $value $text\n";
#        }
#
#   Initialize counter such that results are NOT included in formatting
#   and use it for tracking some event.
#
#        $counter->init("nextSequence", "-internal-");
#
#        $nextSequence = $counter->incr('nextSequence');
#        
#
# ToDo: Document the "format" method, and include some examples of
#       using with the "init","start","end" methods (etc) that are
#       able to create some interesting results.
#
#        $counter->start  ("   Script Started:  ", $starttime);
#        $counter->end    ("     Script Ended:  ");
#        $counter->elapsed("     Elapsed Time:  ");
#
#        print $counter->format;
#

package PTools::Counter;
use strict;
use warnings;

our $PACK    = __PACKAGE__;
our $VERSION = '0.08';
our @ISA     = qw( );

use PTools::String;                         # Some misc. string functions
use PTools::Date::Format;                   # time2str("%c" time);
use PTools::Time::Elapsed;                  # Elapsed time formatter

my $DateFmt = "PTools::Date::Format";
my $Elapsed = "PTools::Time::Elapsed";

sub new
{   my $self = bless {}, ref($_[0])||$_[0];   # $self is a simple hash ref.
    $self->{_list} = [];
    $self->{_tmFormat} = "%C";
    return $self;
}
### set    { $_[0]->{$_[1]}=$_[2]         }   # Note that the 'param' method
### get    { return( $_[0]->{$_[1]}||"" ) }   #    combines 'set' and 'get'
### param  { $_[2] ? $_[0]->{$_[1]}=$_[2] : return( $_[0]->{$_[1]}||"" )  }
sub setErr { return( $_[0]->{STATUS}=$_[1]||0, $_[0]->{ERROR}=$_[2]||"" ) }
sub status { return( $_[0]->{STATUS}||0, $_[0]->{ERROR}||"" )             }
sub stat   { ( wantarray ? ($_[0]->{ERROR}||"") : ($_[0]->{STATUS} ||0) ) }
sub err    { return($_[0]->{ERROR}||"")                                   }

sub value 
{   my($self,$counter) = @_;
    defined $self->{$counter} or 
	return $self->setErr(-1,"Counter '$counter' undefined in '$PACK'");
    return $self->{$counter}->{value} ||0;
}

sub incr 
{   my($self,$counter,$incr) = @_;
    defined $self->{$counter} or 
	return $self->setErr(-1,"Counter '$counter' undefined in '$PACK'");
    $incr = 1 unless defined $incr;
    return $self->{$counter}->{value} += $incr;   # both set and return value
}

sub decr 
{   my($self,$counter,$decr) = @_;
    defined $self->{$counter} or 
	return $self->setErr(-1,"Counter '$counter' undefined in '$PACK'");
    # Note: counter can decrement past zero
    $decr = 1 unless defined $decr;
    return $self->{$counter}->{value} -= $decr;   # both set and return value
}

sub reset
{   my($self,$counter,$value) = @_;
    defined $self->{$counter} or 
	return $self->setErr(-1,"Counter '$counter' undefined in '$PACK'");
    $self->{$counter}->{value} = ($value || 0);
    return;
}

sub init
{   my($self,$counter,$word,$plural,$singular) = @_;
    $counter or
	return $self->setErr(-1,"Required param 'counter' missing in '$PACK'");
    return if grep(/^$counter$/, @{ $self->{_list} });

    $self->{$counter} = {};
    $self->{$counter}->{value} = 0;

    if ($word =~ m#^(-internal-|-hidden-)$#) {
	# set up as internal/hidden counter only
    } else {
	# set up for display via 'format' method
	$self->{$counter}->{_text} = $word     if $word;
	$self->{$counter}->{_plur} = $plural   if $plural;
	$self->{$counter}->{_sing} = $singular if $singular;
	push( @{ $self->{_list} }, $counter);
    }
    return;
}

sub del
{   my($self,$counter) = @_;
    $counter or
	return $self->setErr(-1,"Required param 'counter' missing in '$PACK'");
    delete $self->{$counter};

    return;
}

   *get = \&result;

sub result
{   my($self,$counter,$word,$plural,$singular) = @_;

    if (! defined $self->{$counter}) {
	$self->setErr(-1,"Counter '$counter' undefined in '$PACK'");
	return "";
    }
    my($value,$text,$plur,$sing) = ("","","","");

    $value = $self->{$counter}->{value} || 0;

    if ($word) {
	$text = $word     || "";
	$plur = $plural   || "";
	$sing = $singular || "";
    } else {
	$text = $self->{$counter}->{_text} ||"";
	$plur = $self->{$counter}->{_plur} ||"";
	$sing = $self->{$counter}->{_sing} ||"";
    }
    my $result_text  = PTools::String->plural($value,$text,$plur,$sing);
    my $result_value = PTools::String->addCommasToNumber( $value );

    return( $result_text, $result_value ) if wantarray;
    return("$result_text $result_value" ) if $result_text;
    return( $result_value );
}

sub list
{   my($self) = @_;
    return( @{ $self->{_list} } ) if wantarray;
    return( join(":", @{ $self->{_list} }) );
}

sub head
{   my($self,$text) = @_;
    $self->{_head} = $text ||"";
    return;
}

sub foot
{   my($self,$text) = @_;
    $self->{_foot} = $text ||"";
    return;
}

sub start
{   my($self,$text,$time) = @_;

    $self->{start}->{_text} = $text ||"";
    $self->{start}->{_time} = $time || time;
    return;
}

sub end
{   my($self,$text,$time) = @_;

    $self->{end}->{_text} = $text ||"";
    $self->{end}->{_time} = $time ||0;
    return;
}

*cumula   = \&cumulative;
*cumulate = \&cumulative;

sub cumulative
{   my($self,$text,$time) = @_;

    $self->{cumula}->{_text} = $text ||"";
    $self->{cumula}->{_time} = $time ||0;
    return;
}

*acume = \&accumulate;

sub accumulate
{   my($self,$time) = @_;
    return $self->{cumula}->{_time} += $time;
}

sub elapsed
{   my($self,$text,$time) = @_;

    $self->{elapsed}->{_text} = $text ||"";
    $self->{elapsed}->{_time} = $time || time;
    return;
}

sub tmFormat { $_[1] ? $_[0]->{_tmFormat}=$_[1] : ( $_[0]->{_tmFormat}||"" )  }

#sub tmFormat
#{   my($self,$tmFormat) = @_;
#
#    $self->{_tmFormat} = $tmFormat ||"";
#    return;
#}

sub format
{   my($self,$header,$footer,$nonZeroOnly,$tmFormat,@counterList) = @_;

    $header      ||= $self->{_head}     || "";
    $footer      ||= $self->{_foot}     || "";
    $tmFormat    ||= $self->{_tmFormat} ||"%C";
    $nonZeroOnly ||= "";     # flag to include only non-zero counters
    (@counterList) or (@counterList) = $self->list;
    #
    # Example of adding formatting to Counter results.
    # Note: Counters will be listed here in the order in which they
    #       were "initialized". Change this via "@counterList" param.
    #
    my(@text,@val) = ();
    my($text,$val) = ("",0);
    my($start,$end,$cumula,$elapsed) = (0,0,0,0);
    my $len = 0;
    foreach my $counter ( @counterList ) {
	next unless defined $self->{$counter};
	($text,$val) = $self->result($counter);
	$val or next if $nonZeroOnly;
	$val  ||= "0";
	$text ||= $counter;
	push(@text,$text);
	push(@val, $val);
	$len = ( length($val) > $len ? length($val) : $len );
    }
    $start = $self->{start}->{_time}  || 0;
    $end   = $self->{end}->{_time}    || time;
    $cumula= $self->{cumula}->{_time} || 0;

    $text  = "";
    $text .= "$header\n" if $header;
    foreach my $idx ( 0 .. $#text ) {
	$text .= $text[$idx] . PTools::String->justifyRight( $val[$idx], $len ) ."\n";
    }
    if ($self->{start}->{_text}) {
    	$text .= $self->{start}->{_text};
    	$text .= $DateFmt->time2str($tmFormat, $start) ."\n";
    }
    if ($self->{end}->{_text}) {
    	$text .= $self->{end}->{_text};
    	$text .= $DateFmt->time2str($tmFormat, $end) ."\n";
    }
    if ($self->{cumula}->{_text}) {
    	$text .= $self->{cumula}->{_text};
    	$text .= $Elapsed->convert( $cumula ) ."\n";
    }
    if ($self->{elapsed}->{_text}) {
    	$text .= $self->{elapsed}->{_text};
    	$text .= $Elapsed->convert( $start, $end ) ."\n";
    }
    $text .= "$footer" if $footer;
    return $text;
}

sub dump {
    my($self,$counter)= @_;
    my($pack,$file,$line)=caller();
    my $text  = "DEBUG: ($PACK\:\:dump) self='$self'\n";
       $text .= "CALLER $pack at line $line ($file)\n";
    #
    # The following assumes that the current object 
    # is a simple hash ref ... modify as necessary.
    #
    foreach my $param (sort keys %$self) {
	$text .= " $param = $self->{$param}\n";
        if ( ($param =~ m#$counter#) or ($counter =~ m#all#) ) {
	    next if $param =~ m#^_#;
	    next unless ref $self->{$param};
	    $text .= " -- expanding $param --\n";
	    foreach my $key (sort keys %{$self->{$param}}) {
		$text .= " $key = $self->{$param}->{$key}\n";
	    }
	    $text .= " -- end of $param --\n\n";
	}
    }
    $text .= "_" x 25 ."\n";
    return($text);
}
#_________________________
1; # required by require()

__END__

=head1 NAME

PTools::Counter - Maintain counters; format syntactically correct results.

=head1 VERSION

This document describes version 0.08, released April, 2005.

=head1 SYNOPSIS

=over 4

     use PTools::Counter;
     $counter = new PTools::Counter;

Initialize some counters

     $counter->init("error", "    Errors: ");
     $counter->init("warn",  "  Warnings: ");

Increment a counter

     $counter->incr("warn");


Display some results

     # The following will generate output that resembles:
     #   Warnings:  1
     #     Errors:  0

     foreach my $counterName ("warn","error") {
         print $counter->result( $counterName ) ."\n";
     }

     # The following will generate output that resembles:
     #     Errors: 0   Warnings: 1

     print $counter->result('error'), " ", $counter->result('warn'), "\n";


     # Note: using "dot" to concatenate strings invokes
     # method in "scalar" context, while using a comma
     # to concatenate invokes method in "array" context.
     # There may be some differences in the results.

Initialize counters such that results are syntactically correct

     $counter->init("error", "Descrepenc","ies","y");
     $counter->init("warn",  "Warning","s");

Obtain results that are suitable for additional formatting

     # The following will generate output that resembles:
     #    Found 0 Descrepencies
     #    Found 1 Warning

     foreach my $counterName ("error","warn") {
         ($text,$value) = $counter->result( $counterName );
         print "Found $value $text\n";
     }

Initialize counter such that results are NOT included in formatting
and use it for tracking some event.

     $counter->init("nextSequence", "-internal-");

     $nextSequence = $counter->incr('nextSequence');

=back

=head1 DEPENDENCIES

PTools::String, PTools::Date::Format and PTools::Time::Elapsed.

=head1 DESCRIPTION

=head2 Constructor

=over 4

=item new ( )

Create a new object used to manage various counter values.

 use PTools::Counter;

 $countObj = new PTools::Counter;

=back


=head2 Methods

=over 4

=item init ( CounterName "-internal-" )

=item init ( CounterName [, Word, Plural [, Singular ] ] )

Initialize a counter variable named by B<CounterName>. Optionally
can add text that will be used via the B<format> method to create
syntactically correct results.

Use the special B<Word> "-internal-" to prevent the counter from
being included in any text returned by the B<format> method.

=over 4

=item CounterName

The name used to access a particular counter value by other methods
in this class.

=item Word

The singular (or base) of a word used to describe a particular counter

=item Plural

The plural ending for B<Word>.

=item Singular

Any additional characters required for a singular instance of B<Word>.

=back

Examples:

     $counter->init("error", "Descrepenc","ies","y");

     $counter->init("warn",  "Warning","s");

     $counter->init("nextSequence", "-internal-");


=item incr ( CounterName [, IncrValue ] )

=item decr ( CounterName [, DecrValue ] )

Increment or decrement a B<CounterName>. Default is to add or subtract one.
Pass an additional integer value for a different increment or decrement.

=over 4

=item CounterName

The name used to access a particular counter value.

=item IncrValue

=item DecrValue

Value for an increment or decrement.

=back


=item del ( CounterName )

Delete the counter named B<CounterName> from the counter object.


=item reset ( CounterName [, NewValue ] )

Reset the counter named B<CounterName> to zero.


=item value ( CounterName )

Return the current value for the counter named B<CounterName>.


=item list

Return an array (in list context) or a colon-separated string
(in scalar context) of the currently defined B<CounterNames>.

 (@counterList) = $countObj->list;

 $counterList   = $countObj->list;


=item get ( CounterName [, Word, Plural [, Singular ] ] )

=item result ( CounterName [, Word, Plural [, Singular ] ] )

Create a formatted result for the counter named B<CounterName>
using the current value of the counter.

Parameters are indentical as described in the B<init> method, above.

Also see the B<format> method, below, for a discussion of a
more flexible way to display counter results.


=item head ( [ Text ] )

Set heading text used by the B<format> method.

=item foot ( [ Text ] )

Set footing text used by the B<format> method.

=item start ( [ Text ] [, Time ] )

Set "start time" text used by the B<format> method.

=item end ( [ Text ] [, Time ] )

Set "end time" text used by the B<format> method.

=item elapsed ( [ Text ] [, Time ] )

Set "end time" text used by the B<format> method.


=item tmFormat ( [ TimeFormat ] )

Return or set the B<TimeFormat> string used to control the display
of the B<ElapsedTime> value, when used.

=over 4

=item TimeFormat

Specify a date(1) format string as supported by the B<Time::Format> class.

 Default: "%C"                         # Wed Nov 22 21:05:57 2000

 Example: "%a, %d-%b-%Y %I:%M:%S %p"   # Wed, 22-Nov-2000 09:05:39 pm

 Example: "%d-%b-%Y.%I:%M:%S"          # 22-Nov-2000.09:05:39

=back


=item format ( [ Header ] [, Footer ] [, NonZeroOnly ] [, TimeFormat ] [, CounterList ] )

The B<format> method is used to create text from the current state
of the current object.

=over 4

=item Header

Heading text used during formatting.

=item Footer

Footing text used during formatting.

=item NonZeroOnly

Flag to indicate that any counters with a current value of zero
should B<not> be included in the resulting formatted text.

=item TimeFormat

The B<TimeFormat> string used to control the display of the B<ElapsedTime>
value, when used. See the B<tmFormat> method, above, for examples.

=item CounterList

Pass an array (list) of B<CounterName>s to be included in the resulting
formatted text. By default all counters are included except I<internal>
counters. Also see the B<NonZeroOnly> flag, above.

=back

Examples:

 ToDo:
 Document the "format" method, and include some examples of
 using with the "init","start","end" methods (etc) that are
 able to create some interesting results.
 
 $counter->start   ("   Script Started:  ", $starttime);
 $counter->end     ("     Script Ended:  ");
 $counter->cumulate("  Cumulative Time:  ");        # is optional
 $counter->elapsed ("     Elapsed Time:  ");
 
 ...
 $counter->incr('warn');
 $counter->accumulate( $seconds );
 ...

 print $counter->format;

=back

=head1 INHERITANCE

None currently.

=head1 AUTHOR

Chris Cobb, E<lt>nospamplease@ccobb.netE<gt>

=head1 COPYRIGHT

Copyright (c) 2002-2007 by Chris Cobb. All rights reserved.
This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut


sub setErr { return( $_[0]->{STATUS}=$_[1]||0, $_[0]->{ERROR}=$_[2]||"" ) }
sub status { return( $_[0]->{STATUS}||0, $_[0]->{ERROR}||"" )             }

sub value   \
xub incr     \
xub decr       These 
xub reset      methods can
xub init       call setErr
xub del      /
sub result  /

sub list
sub head
sub foot
sub start
sub end
sub elapsed
sub tmFormat { $_[1] ? $_[0]->{_tmFormat}=$_[1] : ( $_[0]->{_tmFormat}||"" )  }
sub format

