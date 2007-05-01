# -*- Perl -*-
#
# File:  PTools/Date/Format.pm
# Desc:  Modifies the interface and behavior of the "Date::Format" class
# Date:  Fri Jul 09 14:13:24 2004
# Stat:  Production
#
# Procedural Synopsis:
#        use PTools::Date::Format qw( :orig );
#        use PTools::Date::Format qw( :orig date1 );
#        use PTools::Date::Format qw( time2str strftime );
#        use PTools::Date::Format qw( time2str date1 );
#
#        print time2str("%c is day %u in week %U%n", time());
#
# Object Oriented Synopsis:
#        use PTools::Date::Format;
#        use PTools::Date::Format qw( date1 );
#
#        $date = new PTools::Date::Format;
#        $date = "PTools::Date::Format";
#
#        print $date->time2str("%c is day %u in week %U%n", time());
#
# Abstract:
#        Usage can be identical to the Date::Format class. This class 
#        can add/modify formatting directives available in the base class
#        to make things "more compatible" with the Unix date(1) command
#        (this does not add implementation for "Emperor/Era" directives).
#
#        Modified Directives
#        %c  - Current date/time:  For example, Fri Jul  9 15:42:02 PDT 2004
#        %C  - Century two-digit:  For example, 20
#
#        Additional Directives
#        %u  - Weekday, ordinal:   1 = Monday, through 7 = Sunday
#
# Note:  The "@EXPORT" list is accurate as of Date::Format VERSION 2.22.
#

package PTools::Date::Format;
use strict;
use warnings;
no warnings "redefine";

use vars qw( $PACK $VERSION @ISA @ORIG @ALL @EXPORT @EXPORT_OK %EXPORT_TAGS);
$PACK    = __PACKAGE__;
$VERSION = '0.05';
@ISA     = qw( Date::Format );   ##Exporter );      # inheritance hierarchy
@ORIG    = qw( time2str strftime ctime asctime );   # maintain orig exports
@ALL     =   ( @ORIG, );                            # no additions, for now

@EXPORT_OK   = @ORIG;
%EXPORT_TAGS = ( 
          'orig' => [ @ORIG ],
       'default' => [ @ORIG ],
	   'all' => [ @ALL  ],
	       );

use Date::Format;            # always the 1st parent class
use Exporter;                # optionally 2nd parent class

sub import
{   my($class,@args) = @_;

my $objectSubs = <<'__EndOfObjectSubs';
    my $FmtClass = "Date::Format::Generic";
    my $Format_c = "%a %b %e %T %Y";
    sub new              { bless [], ref($_[0])||$_[0] }
    sub time2str ($;$$)  { shift; $FmtClass->time2str(@_) }
    sub strftime ($\@;$) { shift; $FmtClass->strftime(@_) }
    sub ctime    ($;$)   { $FmtClass->time2str("$Format_c\n", $_[1], $_[2]) }
    sub asctime  (\@;$)  { $FmtClass->strftime("$Format_c\n", $_[1], $_[2]) }
__EndOfObjectSubs

my $modifiedSubs = <<'__EndOfModifiedSubs';
    package Date::Format::Generic;
    sub format_c { my $f="%a %b %e %T %Y"; _subs( $_[0], $f ) }
    sub format_C { substr( &format_Y, 0, 2 ) }
    sub format_u { &format_w || 7 }
__EndOfModifiedSubs

my $errorSubs = <<'__EndOfErrorSubs';
    my $error= "Error: OO Interface must be configured during 'use' for $PACK";
    sub new { die "$error\n" }
__EndOfErrorSubs

    # PART I: Configure the conversion specification
    #
    my $modDate = 0;
    if (grep/^date1$/, @args) {         # Modify the conversion specification

	eval $modifiedSubs;
	$@ and die "Error: failed to eval 'modified subs': $@";
	$modDate = 1;
    }
    
    # PART II: Configure the interface
    #
    if (! @args || $args[0] eq "date1") {   # Define Object Oriented Interface
	my(@tagCheck) = @EXPORT_OK;
	map { push @tagCheck, ":$_" } keys %EXPORT_TAGS;
	my $error = "Error: mutually exclusive tags used during import";
	foreach my $tag (@args) { grep(/^$tag$/, @tagCheck) and die $error }

	eval $objectSubs;
	$@ and die "Error: failed to eval 'object subs': $@";

    } else {              # Make this module equivalent to the original class
	if ($modDate) {
	    # Note: here we must strip out the 'date1' argument.
	    # We only need to do this if we modified the conversion
	    # specs, above. Otherwise, Exporter complains that 'date1' 
	    # is not 'exportable'.

	    foreach my $idx ( 0..$#args ) {
		splice(@args, $idx, 1) if $args[$idx] eq "date1" 
	    }
	}
	push @ISA, "Exporter";
	$class->export_to_level(1, $class,@args);

	eval $errorSubs;
	$@ and die "Error: failed to eval 'error subs': $@";
    }
    return;
}
#_________________________
1; # Required by require()

__END__

=head1 NAME

PTools::Date::Format - An OO interface to Date::Format, with additions

=head1 VERSION

This document describes version 0.05, released July, 2004,
and is designed to be compatible with Date::Format 2.22.

=head1 SYNOPSIS

=head2 Procedural Interface

        use PTools::Date::Format qw( :orig );
        use PTools::Date::Format qw( :orig date1 );
        use PTools::Date::Format qw( time2str strftime ctime asctime );
        use PTools::Date::Format qw( time2str strftime date1 );

	print time2str( "%c is day %u in week %U%n", time() );

=head2 Object Oriented Interface

        use PTools::Date::Format;
        use PTools::Date::Format qw( date1 );

        $date = new PTools::Date::Format;
        $date = "PTools::Date::Format";

        print $date->time2str( "%c is day %u in week %U%n", time() );

=head2 Modified Conversion Specification

        use PTools::Date::Format qw( :orig date1 );
        use PTools::Date::Format qw( date1 );


=head1 DESCRIPTION

This module provides routines identical to the B<Date::Format> class.
When 'used', this module can be configured to behave as follows.

 . configured for procedural function calls, just as the parent class
 . configured for object oriented syntax not supported by the parent

 . configured to use the same conversion specifications as the parent
 . configured to use modified conversion specifications similar to date(1)

For this class to act in an identical manner to the original, make sure
to include either the ':orig' directive or all four of the original
function names 'time2str', 'strftime', 'ctime' and 'asctime'. Also make
sure to I<omit> the 'date1' directive to achieve identical behavior
with the conversion specification defined in the parent class.

Once 'used,' the invoking class should not attempt to modify the 
configuration by reissuing the 'use' function. This is not yet
supported by this module, and the results are unpredictable.


=head1 MODIFIED CONVERSION SPECIFICATION

If the 'date1' configuration argument is passed when using this
class, the original conversion specifications are modified to be
'more compatible' with the Unix B<date>(1) formatting directives.

Additions and modifications to the original conversion specification 
includes the following characters.

	%c	Current date and time (eg Fri Jul  9 19:04:05 2004)
	%C 	Century as a two-digit decimal number (eg 20)
	%u      weekday as a one-digit number (Monday == 1, Sunday == 7)


=head1 ERRORS

This class attempts to notify the user of configuration errors.
However, not all errors can be detected by the script but are
caught by the Perl interpreter. The following list includes 
possible problems, their causes and suggested solutions.


=head2 Error: Undefined subroutine _subroutine_name_

The calling script is attempting to invoke a procedural function
that was not imported when this module was 'used.' Make sure that
the invoked function name (or the special tag ':orig') was included 
in the list of configuration parameters.

        use PTools::Date::Format qw( :orig );

        use PTools::Date::Format qw( time2str asctime );

When used as the first example shows, this module will act in
an identical manner to the original B<Date::Format> class.
Note that it is not necessary to import all of the function names 
into the calling program, only the functions that will be invoked.


=head2 Formatting directives don't work as expected

Adding the 'date1' configuration parameter when this class is 'used' 
causes modifications to the conversion specifications as noted, above.

        use PTools::Date::Format qw( :orig date1 );

        use PTools::Date::Format qw( date1 );

If the resulting formatted date string is always 'PTools::Date::Format'
the calling stript is attempting to invoke conversion functions as
'class methods' when the module was configured for procedural usage.

The following example of B<incorrect> usage demonstrates this last
error condition.

        use PTools::Date::Format qw( :orig );

	$date = "PTools::Date::Format";

	print $date->time2str("%c is day %u in week %U%n", time());

The solution is to match the configuration arguments with the usage.
Either omit the ':orig' configuration argument, or invoke conversion 
as subroutine functions and not as class/object methods.

The following is an example of correct B<Procedural> usage.

        use PTools::Date::Format qw( :orig );

	print time2str( "%c is day %w in week %U%n", time() );


=head2 Error: OO Interface must be configured during 'use'

The calling script is attempting to invoke the 'B<new>' method
when this module was configured for Procedural usage.

The following is an example of correct B<Object Oriented> usage.

        use PTools::Date::Format;

	$date = new PTools::Date::Format;
    or  $date = "PTools::Date::Format";

	print $date->time2str("%c is day %w in week %U%n", time());

Note that in this last example, as in the one just above, the '%w'
formatting directive is used (instead of '%u' as was used in other
examples). This is because, without specifying the 'date1' configuration 
directive when using this class, the '%u' directive is not recognized.


=head1 SEE ALSO

See L<Date::Format>.

=head1 AUTHOR

Chris Cobb [no dot spam at ccobb dot net]

=head1 COPYRIGHT

Copyright (c) 2004-2007 by Chris Cobb. All rights reserved.
This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut

