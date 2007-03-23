# -*- Perl -*-
#
# File:  PTools/Verbose.pm
# Desc:  A light-weight class to add verbose levels to Perl scripts/modules.
# Auth:  Chris Cobb, Hewlett-Packard, Cupertino, CA  <chris.cobb@hp.com>
# Date:  Thu Oct 14 01:55:12 2004
# Stat:  Production
#
# Synopsis:
#        use PTools::Verbose;
#
#        $verbose = new PTools::Verbose( $verboseLevel );
#        $verbose = new PTools::Verbose( $verboseLevel, $indentLevel );
#        
#    Note that each of the following method names are equivalent,
#    and there are several other aliases for the "verbose" method
#    including "at", "atLevel", "check", "chk", "print" and "set".
#    This is intended to aid in semantically meaningful method calls.
#
#        $verbose->test( $level );
#        $verbose->warn( $level, $text );
#        $verbose->warn( $level, $text, $max );
#        if ($verbose->isSet) { ... }
#
# See "POD" for additional Synopsis, Description, Usage, etc.
# after the __END__ of this module.

package PTools::Verbose;
use strict;
use warnings;

our $PACK    = __PACKAGE__;
our $VERSION = '0.02';
our @ISA     = qw( PTools::Debug );

use PTools::Debug;     # include parent class

sub version { $VERSION }

sub new
{   my($class, @args) = @_;

    bless my $self = $class->SUPER::new( @args );

    $self->setVerbose();   # reset prefix so we don't spew "DEBUG: " messages.
    $self->resetWarn();    # reset "warn" flag so we spew to STDOUT instead.

    return $self;
}
#_________________________
1; # Required by require()

__END__

=head1 NAME

PTools::Verbose - A light-weight class to provide verbose output levels

=head1 VERSION

This document describes version 0.01, released October, 2004


=head1 SYNOPSIS

 use PTools::Verbose;

 $verbose = new PTools::Verbose( $verboseLevel );
 $verbose = new PTools::Verbose( $verboseLevel, $indentLevel );

Each of the following method names are equivalent. There are other 
aliases for the "level" as shown in the 'Methods' section, below
This is intended to aid in semantically meaningful method calls.

 $verbose->test( $level );
 $verbose->put( $level, $text );
 $verbose->put( $level, $text, $max );
 if ($verbose->isSet) { ... }


=head1 DESCRIPTION

=head2 Constructor

=over 4

=item new ( VerboseLevel [, IndentLevel ] )

The B<new> method is called to create a new object that will 
be used to provide various levels of verbose output, based on
the overall B<VerboseLevel> set within the object combined
with the I<Level> passed into the I<verbose> method, below.

=over 4

=item VerboseLevel

The required B<VerboseLevel> is used to establish the overall level of
output text that will be generated during a given session or run of
a particular script.

=item IndentLevel

An optional B<IndentLevel> can be used to add message indents for each
level of output text. 

When using this parameter, the character indent is calculated by 
multiplying the B<Level> (passed via the B<verbose> method) and the
B<IndentLevel>. Therefore, use of small values for both this number 
and B<Level> is recommended. See the L<Example|"EXAMPLE"> section,
below, for details.

=back

=back


=head2 Methods

=over 4

=item verbose ( [ Level ] [, Message ] [, MaxLevel ] )

This method is designed to be used in various situations.

 .  to generate verbose output on STDERR
 .  to test if a verbose flag was enabled
 .  to determine what level of verbose was enabled

As such there are multiple alias names defined for this
particular method. Additional method names can easily
be defined by subclassing this module.

=over 4

=item Level

When using the B<verbose> method (or any of its aliases) to emit a
text B<Message>, the B<Level> parameter is expected to be an integer
value. This value is tested against the B<VerboseLevel> used when
instantiating an object of this class (or set via the B<setLevel>
method, below). If the test passes, the specified B<Message> is
emitted.

=item Message

The B<Message>, when specified, is a text string that will be emitted
to STDERR. The text will be emitted when the specific B<Level> value
(passed via the B<verbose> method or one of its aliases) is tested against
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
that is used to indent output text. The level of endent is
calculated as a function of the I<IndentLevel> setting and the
I<Verbose Level> passed to the B<verbose> method by the calling
script/module.


=item setLevel  ( VerboseLevel )

Use the B<setLevel> method to determine the amount of output
text that will be generated during a given run of a script
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

=item true

=item warn

These method names are all aliases for the above 'verbose' method.
They can be used interchangably to create clean syntax in the
invoking script/module, depending on the given situation. Notice
the various usage scenarios in the example, below.

=back

=head1 EXAMPLE

 #!/opt/perl/bin/perl -w
 use strict;
 use PTools::Verbose;

 my $verbose      = new PTools::Verbose( @ARGV );
 my $verboseLevel = $verbose->getLevel;    # passed from cmd-line
 my $indentLevel  = $verbose->getIndent ||0;

 print "\n";
 if (defined $verboseLevel) {
     print "Verbose level  = '$verboseLevel'\n";
 } else {
     print "Verbose level  = <undefined>\n\n";
     print "Usage: $0  [ verboseLevel ] [, indentLevel ]\n";
     print "\n";
     print "Note that a 'verboseLevel' of [ 0 - 6 ] is good for a demo,\n";
     print "and that an 'indentLevel' of [ nul - 4 ] is also good demo.\n";
     print "\n";
 }

 if ($verbose->isSet) {
    print "Indent level = '$indentLevel'\n";
    print "\n";
 }

 $verbose->if   ( undef, "Level undef"  );
 $verbose->and  (     0, "Level 0"      );
 $verbose->prn  (     1, "Level 1"      );
 $verbose->print(     2, "Level 2"      );
 $verbose->print(     2, "Level 2-3", 3 );
 $verbose->warn (     3, "Level 3"      );
 $verbose->warn (     3, "Level 3-4", 4 );
 $verbose->if   (     4, "Level 4"      );

 if ($verbose->isSet) {
    if (! $verbose->getIndent) {
       $indentLevel = 4;
       $verbose->setIndent( $indentLevel );
       print "\nIndent level = '$indentLevel'\n";
    }
    print "\n";
 }

  is $verbose( undef, "Level u-*",   2 );
  is $verbose(     0, "Level 0-*",   2 );
  is $verbose(     1, "Level 1-3",   3 );
  at $verbose(     2, "Level 2"      );
  at $verbose(     2, "Level 2-2",   2 );
  at $verbose(     2, "Level 2-3",   3 );
  at $verbose(     3, "Level 3"      );
 chk $verbose(     3, "Level 3-4",   4 );
test $verbose(     3, "Level 3-5",   5 );

 print "\n" if $verbose->isSet;


=head1 INHERITANCE

This class inherits from the Debug class.

=head1 SEE ALSO

See L<Debug>.

=head1 AUTHOR

Chris Cobb, E<lt>nospamplease@ccobb.netE<gt>

=head1 COPYRIGHT

Copyright (c) 2004-2007 by Chris Cobb. All rights reserved.
This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
