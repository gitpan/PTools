# -*- Perl -*-
#
# File:  PTools/Debug.pm
# Desc:  A light-weight class to add debug levels to Perl scripts/modules.
# Date:  Wed Jan 28 16:46:11 2004
# Stat:  Production
#
# Synopsis:
#        use PTools::Debug;
#
#        $debug = new PTools::Debug( $verboseLevel );
#        $debug = new PTools::Debug( $verboseLevel, $indentLevel );
#        
#    Note that each of the following method names are equivalent,
#    and there are several other aliases for the "debug" method
#    including "at", "atLevel", "check", "chk", "print" and "set".
#    This is intended to aid in semantically meaningful method calls.
#
#        $debug->test( $level );
#        $debug->warn( $level, $text );
#        $debug->warn( $level, $text, $max );
#        if ($debug->isSet) { ... }
#
#    Other examples provide for potentially better syntax depending 
#    on the given situation ("ifDebug" is yet another alias for the
#    "debug" method).
#
#        $warn = new PTools::Debug( $verboseLevel, $indentLevel );
#
#        $warn->ifDebug( $level, $text );
#        $warn->debug and do { ... }
#
# See "POD" for additional Synopsis, Description, Usage, etc.
# after the __END__ of this module.
#

package PTools::Debug;
 use strict;

 my $PACK = __PACKAGE__;
 use vars qw( $VERSION @ISA );
 $VERSION = '0.04';
#@ISA     = qw( );


sub new
{   my($class, $verbose, $indent) = @_;

    bless my $self = {}, ref($_[0])||$_[0];    # $self is a hash ref.

    # Establish the overall "verbose level" that the "debug" method 
    # will use to test whether or not debug is "true"
    #
    $self->setLevel( $verbose );
    $self->setPrefix( "DEBUG: ");
    $self->setWarn();

    # If using $indent, 4 is a good value, unless $level will ever get
    # above 5 or so (in the "debug" method, below). Much more than that
    # and 2 is probably a better value for $indent here. It all depends
    # on how long the various $message strings will get.
    #
    $self->setIndent( $indent );

    return $self;
}

sub setIndent  { $_[0]->{INDENT} = $_[1] }
sub getIndent  { $_[0]->{INDENT}         }
sub setLevel   { $_[0]->{LEVEL}  = $_[1] }
sub getLevel   { $_[0]->{LEVEL}          }
sub version    { $VERSION                }

# Added for "Verbose" child class to allow for use 
# without printing "DEBUG: " in the output string.

sub setPrefix  { $_[0]->{PREFIX} = $_[1] }
sub setVerbose { $_[0]->{PREFIX} = ""    }
sub setWarn    { $_[0]->{WARN}   = 1     }
sub resetWarn  { $_[0]->{WARN}   = 0     }

# Provide some aliases so the calling module can create
# semantically meaningful test statements. Strange that
# it's so difficult to come up with a generic method name.
# (It's just due to the many different ways in which this
# module can be used and this method can be invoked.)

   *and     = \&debug;
   *at      = \&debug;
   *atLevel = \&debug;
   *check   = \&debug;
   *chk     = \&debug;
   *dbg     = \&debug;
   *if      = \&debug;
   *ifDebug = \&debug;
   *is      = \&debug;
   *isSet   = \&debug;
   *isTrue  = \&debug;
   *level   = \&debug;
   *lvl     = \&debug;
   *only    = \&debug;
   *print   = \&debug;
   *prn     = \&debug;
   *put     = \&debug;
   *set     = \&debug;
   *test    = \&debug;
   *tell    = \&debug;
   *true    = \&debug;
   *verbosee= \&debug;
   *warn    = \&debug;

sub debug
{   my($self,$level,$message,$max) = @_;
    #
    # Script Usage:   Run script with  [ -D [ <level> ] ]
    #
    # method Usage:   $debug->chk( [ <level> ]  [, <message> ] [, <max> ] );
    #
    # The 'LEVEL' attrib can be set to <nul>, 0 or >0 when module is used
    # the 'level' param  can be set to <nul>, 0 or >0 when method is called
    #
    # Note that when a method "$level" of zero is passed
    # to this subroutine, the result is always TRUE when
    # ANY value for the Script Option DEBUG flag is set.
    #
    # Verbose Level   method
    # $self->{LEVEL}  $level   $result  Notes
    # --------------  -------  -------  ------------------------------------
    # (no -D) undef    undef    False   (A) debug disabled
    #                    0      False   (A) debug disabled
    #                   >0      False   (A) debug disabled
    #
    # (w/ -D)   0      undef    TRUE    (B) keep things correct (semantically)
    #                    0      TRUE    (C) $level == $debug
    #                   >0      False   (D) $level > $debug
    #
    # (-D n)   >0      undef    TRUE    (B) keep things correct (semantically)
    #                    0      TRUE    (C) $level < $debug
    #                   >0      False   (D) IFF $level >  $debug, -or-
    #                   >0      False   (E) IFF $debug >  $max,   -or-
    #                   >0      TRUE    (F) IFF $level <= $debug
    #
    # The "$max" parameter, when used, will limit a "TRUE" result
    # to only Verbose Levels within a range as shown here, but
    # only if the "$level" param value is greater than zero.
    #   return TRUE IFF:   $level >= $debug <= $max 
    #
    # Obviously, order of the following tests is critical for success.
    # Compare results below with the table just above.
    #
    my $debug  = $self->{LEVEL};
    my $result = 0;

    if (! defined  $debug ) {             # (A) run w/o -D, debug disabled
	$result =  0;
    } elsif (! defined $level ) {         # (B) must, for semantic correctness
	$result =  1;
    } elsif (! $level ) {                 # (C) may seem a pathological case
	$result =  1;
    } elsif ( $level > $debug ) {         # (D) $level > $debug
	$result =  0;
    } elsif ( $max and $debug > $max ) {  # (E) $debug > $max
	$result =  0;
    } else {                              # (F) $level <= $debug
	$result =  1;
    }

    # Check to see if we are going to emit a warning message
    # If so, check to see if we will indent the text based
    # on the current "$level". 
    #
    if ($result and defined $message) {
	my($indent, $prefix, $spaces) = ($self->{INDENT}, $self->{PREFIX}, "");
	$indent and $spaces = " " x ($level * $indent);
	if ($self->{WARN}) {
	    warn "${spaces}${prefix}$message\n"  
	} else {
	    print "${spaces}${prefix}$message\n"  
	}
    }
    return $result;
}

sub dump
{   my($self) = @_;

    my($text)= "DEBUG: ($PACK) self='$self'\n";
    my($pack,$file,$line)=caller();
    $text .= "CALLER $pack at line $line ($file)\n";

    my $value;
    foreach my $key (sort keys %$self) {
        $value = $self->{$key};
        $value = $self->zeroStr( $value, "" );  # handles value of "0"
        $text .= " $key = $value\n";
    }
    $text .= "____________\n";
    return($text);
}

sub zeroStr
{   my($self,$value,$undef) = @_;
    return $undef unless defined $value;
    return "0"    if (length($value) and ! $value);
    return $value;
}

#sub import
#{   my($class,$method) = @_;
#
#    my($pack,$file,$line)=caller();
#    print "IMPORT: define method '$method' in class '$pack'\n";
#    no strict "refs";
#    *{"$pack\::$method"} = \&debug;  # incomplete.
#
#    return;
#}
#_________________________
1; # Required by require()

__END__

=head1 NAME

PTools::Debug - A light-weight class to provide debug output levels.

=head1 VERSION

This document describes version 0.04, released October, 2004


=head1 SYNOPSIS

 use PTools::Debug;

 $debug = new PTools::Debug( $verboseLevel );
 $debug = new PTools::Debug( $verboseLevel, $indentLevel );

Each of the following method names are equivalent. There are other 
aliases for the "level" as shown in the 'Methods' section, below
This is intended to aid in semantically meaningful method calls.

 $debug->test( $level );
 $debug->warn( $level, $text );
 $debug->warn( $level, $text, $max );
 if ($debug->isSet) { ... }

Other examples provide for potentially better syntax depending 
on the given situation. These are equivalent to the above.

 $warn = new PTools::Debug( $verboseLevel, $indentLevel );

 $warn->ifDebug( $level, $text );
 $warn->debug and do { ... }


=head1 DESCRIPTION

=head2 Constructor

=over 4

=item new ( VerboseLevel [, IndentLevel ] )

The B<new> method is called to create a new object that will 
be used to provide various levels of debug output, based on
the overall B<VerboseLevel> set within the object combined
with the I<Level> passed into the I<debug> method, below.

=over 4

=item VerboseLevel

The required B<VerboseLevel> is used to establish the overall level of
debug output that will be generated during a given session or run of
a particular script.

=item IndentLevel

An optional B<IndentLevel> can be used to add message indents for each
level of debug message. 

When using this parameter, the character indent is calculated by 
multiplying the B<Level> (passed via the B<debug> method) and the
B<IndentLevel>. Therefore, use of small values for both this number 
and B<Level> is recommended. See the L<Example|"EXAMPLE"> section,
below, for details.

=back

=back


=head2 Methods

=over 4

=item debug ( [ Level ] [, Message ] [, MaxLevel ] )

This method is designed to be used in various situations.

 .  to generate debug output on STDERR
 .  to test if a Debug flag was enabled
 .  to determine what level of Debug was enabled

As such there are multiple alias names defined for this
particular method. Additional method names can easily
be defined by subclassing this module.

=over 4

=item Level

When using the B<debug> method (or any of its aliases) to emit a
text B<Message>, the B<Level> parameter is expected to be an integer
value. This value is tested against the B<VerboseLevel> used when
instantiating an object of this class (or set via the B<setLevel>
method, below). If the test passes, the specified B<Message> is
emitted.

=item Message

The B<Message>, when specified, is a text string that will be emitted
to STDERR. The text will be emitted when the specific B<Level> value
(passed via the B<debug> method or one of its aliases) is tested against
the overall B<VerboseLevel> (used when instantiating an object of this
class, or set via the B<setLevel> method).

=item MaxLevel

The B<MaxLevel> is an optional parameter that is used to further limit
when the specified B<Message> will be emitted. See examples, below.

=back

=back


=over 4

=item setIndent ( IndentLevel )

Use the B<setIndent> method at any time to set an B<IndentLevel>
that is used to indent debug output. The level of endent is
calculated as a function of the I<IndentLevel> setting and the
I<Debug Level> passed to the B<debug> method by the calling
script/module.


=item setLevel  ( VerboseLevel )

Use the B<setLevel> method to determine the amount of debug
output that will be generated during a given run of a script
or module that uses this class.


=item getLevel

Use the B<getLevel> method to obtain the current I<VerboseLevel>
setting.


=item version

Use the B<version> method to obtain the current class version.


=item and

=item at

=item atLevel

=item check

=item chk

=item dbg

=item if

=item ifDebug

=item is

=item isSet

=item isTrue

=item level

=item lvl

=item only

=item print

=item prn

=item put

=item set

=item test

=item tell

=item true

=item warn

These method names are all aliases for the above 'debug' method.
They can be used interchangably to create clean syntax in the
invoking script/module, depending on the given situation. Notice
the various usage scenarios in the example, below.

=back

=head1 EXAMPLE

 #!/opt/perl/bin/perl -w
 use strict;
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


=head1 AUTHOR

Chris Cobb [no dot spam at ccobb dot net]

=head1 COPYRIGHT

Copyright (c) 2004-2007 by Chris Cobb. All rights reserved.
This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
