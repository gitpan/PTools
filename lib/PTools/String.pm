# -*- Perl -*-
#
# File:  PTools/String.pm
# Desc:  Misc string functions not explicitly provided in Perl
# Stat:  Production
#
# Index of methods:
#  . addCommasToNumber     - Place commas into large numbers
#  . centerInBuffer        - Center a string in a buffer
#  . justifyRight          - Right justify a string in a buffer
#  # justifyListRight      - Right justify list of strings (w/comma option)
#  . initialCaps           - Shift case on words within a string
#  . stripExtraWhiteSpace  - Strip leading, trailing, extra whitespace, and
#                            in list context, also return array ref of words
#  . stripLeftWhiteSpace   - Strip leading whitespace
#  . stripRightWhiteSpace  - Strip trailing whitespace
#  . zero                  - Handle strings that may have value of "0" or ""
#  . plural                - Calculate word (singular/plural) based on counter
#  . prompt                - Prompt and get input, with optional edits
#  . untaint / detaint     - Untaint a string of text
#  . isTainted             - Check a string of text for 'taintedness'
#

package PTools::String;
use strict;

my $PACK = __PACKAGE__;
use vars qw( $VERSION @ISA );
$VERSION = '0.18';
#@ISA     = qw( );                         # defines interitance relationships


sub new { bless {}, ref($_[0])||$_[0]  }   # not needed: added for convenience

sub addCommasToNumber
{   my($class,$string,$forceDecimal) = @_;

    $string = reverse $string;
    $string =~ s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g;
    $string =~ s/^(\d)\./0$1./;        # remember, it's still reversed here ;-)

    # FIX: this next only force-adds ".00" to the LAST 
    # number in a string of text/numbers.
    #
    $string =~ s/^(\D*)(\d\d)(?!\.)/${1}00.$2/g if $forceDecimal;

    return scalar reverse $string;
}


sub centerInBuffer
{   my($class,$string,$bufLen) = @_;

       $bufLen = int($bufLen)    or return "";
    my $strLen = length($string) or return "";
    my $buffer = " " x $bufLen;

    if ($bufLen > $strLen) {
	my $start = int($bufLen / 2) - int($strLen / 2);
	my $end   = $start + $strLen;
	$start-- if ($start + $end) > $bufLen;
	substr($buffer,$start,$strLen) = $string;
    } else {
	$buffer = substr($string,0,$bufLen);
    }
    return($buffer);
}


sub justifyRight
{   my($class,$string,$bufLen) = @_;

       $bufLen = int($bufLen)    or return "";
    my $strLen = length($string) or return "";
    return $string unless $bufLen > $strLen;

    my $buffer = " " x $bufLen;
    my $start  = int($bufLen) - length($string);

    substr($buffer,$start,$bufLen) = $string;

    return($buffer);
}

sub justifyListRight
{   my($class,$arrayRef,$commaFlag,$bufLen) = @_;

    return unless (ref($arrayRef) eq "ARRAY");

    my($val,$len,$tmp) = ("",0,0);

    foreach my $idx (0 .. $#{ $arrayRef }) {
	$val = $arrayRef->[$idx];
	if ($commaFlag) {
	    $val = $class->addCommasToNumber( $val );
	    $arrayRef->[$idx] = $val;
	}
        $tmp = length( $val );
        $len = $tmp if $tmp > $len;
    }

    foreach my $idx (0 .. $#{ $arrayRef }) {
        $arrayRef->[$idx] = $class->justifyRight( $arrayRef->[$idx], $len );
    }
    return;
}

sub initialCaps
{   my($class,$string) = @_;
    join ' ', map { ucfirst(lc($_)) } split(' ', $string);
}


sub stripExtraWhiteSpace
{   my($class,$string) = @_;

    my (@tokens) = split(/\s+/, $string);
    $tokens[0] or shift(@tokens);
    $string = join ' ', @tokens;

    return($string, \@tokens) if wantarray;
    return($string);
}


sub stripLeftWhiteSpace
{   my($class,$string) = @_;

    $string =~ s/^\s+//go;
    return($string);
}


sub stripRightWhiteSpace
{   my($class,$string) = @_;

    $string =~ s/\s+$//go;
    return($string);
}


# As we *so* often have to code around the fact that
# ("0" eq ""), do it once and for all! Here and now!
#
# Usage:   $value = PTools::String->zero( $value [, $valWhenUndef ] );
#
# E.g.:    # The usual "value or default" constructs:
#          $value = $someNumberValue ||"0";
#          $value = $someStringValue ||"";
#
#          # Now we can get "$value" OR "" OR "0" OR "undef"
#          $value = PTools::String->zero( $someStringValue);
#
#          # And can also provide a default for "undef" strings
#          $value = PTools::String->zero( $someStringValue, "0" );
#
# .  If $value" is undefined, return whatever was
#    passed in the "$undef" variable which, by
#    default, will be "undef" (whada coincidence).
#
# .  If "$value" has length but tests FALSE, return "0".
#
# .  Otherwise, return the original "$value".

   *zeroString = \&zero;
   *zeroStr    = \&zero;

sub zero
{   my($class,$value,$undef) = @_;
    return $undef unless defined $value;
    return "0"    if (length($value) and ! $value);
    return $value;
}


# Usage: 
#   PTools::String->plural( $counter, $word ,$pluralSuffix [,$singularSuffix] );
# Example:
#   use PTools::String;
#   $strUtil       = "PTools::String";
#   $descrepancies = $strUtil->plural( $errCount,  "descrepanc", "ies", "y");
#   $replicas      = $strUtil->plural( $replCount, "replica",    "s");
#   print "Found $errCount $descrepancies in $replCount $replicas\n";

sub plural
{   my($class,$count,$word,$plural,$singular) = @_;

    return "" unless (length($count) and $word);
    return($count == 1 ? $word . ($singular ||"") : $word . ($plural ||""));
}


# Usage: PTools::String->prompt( $promptText [, $matchCriteria [, $errorText ]] );
# Example: 
#   use PTools::String;
#   $strUtil= "PTools::String";
#   $uname  = $strUtil->prompt("  User name: ", "^([a-z])\\w{0,7}\$"     );
#   $empno  = $strUtil->prompt(" Emp Number: ", "^(\\d{1,8}|N\\d{1,7})\$");
#   $telnet = $strUtil->prompt(" Emp Telnet: ", "^(|\\d{3}-\\d{4})\$"    );
#   $email  = $strUtil->prompt("     E-Mail: ", ""                       );
#   $uid    = $strUtil->prompt("     UserID: ", "^\\d{1,5}\$"            );
#   $gid    = $strUtil->prompt("    GroupID: ", "^\\d{1,5}\$"            );
#
# Notice that "" will pass edit for both 'telnet' and 'email' variables;
# however, if a value IS entered for 'telnet' it must match the pattern.

   *promptUser  = \&prompt;
   *promptStdin = \&prompt;

sub prompt
{   my($class,$prompt,$editMatch,$errMsg,$default,@exitStr) = @_;

    $errMsg ||= "\n   * * Oops: invalid input * *\n\n";
    @exitStr  = qw( // / )  unless scalar(@exitStr);

    # Note: Contstruct match tests here allowing for Perl's match char(s)
    # in the string under test w/o generating Perl warning messages about
    # null match strings, etc. Basically this means 'escaping' any match 
    # chars in the "exitString(s)" and using syntax where "input" string
    # is the subject of the test (left side) not the object (right side).

    # This first "map" escapes "special char(s)" with a single "\" char.
    # FIX? combine the following two substitutions into a single match?

    map { s#\\([*!?+.])#$1#go;  s#([*!?+.])#\\$1#go } @exitStr;

    my($input,$invalid) = ("",1);      # assume the worst, until edit passes

    while ($invalid) {
	print "$prompt";                                     # prompt user

	$input=<>;
	return($exitStr[0] ||undef) unless defined $input;   # handle Ctrl-D

	chomp $input;
	length $input or ( $input = $default ||"" );         # handle CR/LF

	# Here we return to the caller if an "exit string" was entered.
	# Note that the default "exit strings" still allow for entering 
	# filenames with forward slash characters.

	map { return($input) if $input =~ /^$_$/ } @exitStr;

	## If the calling module passed a default string and this is 
	## exactly what we recieved as input, skip the edit check.
	## NOT!
	#(defined $default) and (return $input) if ($input eq $default);

	# If the calling module passed an "editMatch" string then run the
	# match. If it passes, or if no edit was passed, the input is ok.

	$invalid = ( $editMatch ? ( $input =~ /$editMatch/ ? 0 : 1 ) : 0 );

	print $errMsg if $invalid;                           # print "hint"
    }
    return($input);                                          # all done.
}

# Usage: 
#   $text = PTools::String->detaint( $text [, $allowedCharList ] );
#   $text = PTools::String->untaint( $text [, $allowedCharList ] );
#
# Any character not in the "$allowedCharList" becomes an underscore ("_")
# The default "$allowedCharList" includes those characters identified in
# "The WWW Security FAQ" with the addition of the space (" ") character.

*detaint = \&untaint;

sub untaint
{   my($class, $text, $allowedChars) = @_;

    $allowedChars ||= '- a-zA-Z0-9_.@';      # default allowed chars

    $text =~ s/[^$allowedChars]/_/go;        # replace disallowed chars
    $text =~ m/(.*)/;                        # untaint using a match
    return $1;                               # return untainted match
}

# Usage: 
#   if (PTools::String->isTainted( $text )) { ... }

sub isTainted
{   my($class, $text) = @_;
    my $nada = substr($text,0,0);
    local $@;
    eval { eval "# $nada" };
    return length($@) != 0;
}
#_________________________
1; # required by require()

__END__

=head1 NAME

PTools::String - Misc string functions not explicitly provided in Perl

=head1 VERSION

This document describes version 0.16, released December, 2005.

=head1 SYNOPSIS

 use PTools::String;

 $strObj = new PTools::String;

 $result = $strObj->addCommasToNumber( $bigNumber );

 $result = $strObj->centerInBuffer( $string, $bufferLength );

 $result = $strObj->justifyRight( $string, $bufferLength );

 $result = $strObj->justifyListRight( $arrayRef [,"commaFlag"] [,$bufferLength]);

 $result = $strObj->initialCaps( $string );

 $result = $strObj->stripExtraWhiteSpace( $string );

 $result = $strObj->stripLeftWhiteSpace( $string );

 $result = $strObj->stripRightWhiteSpace( $string );

 $result = $strObj->zero( $value );

 $result = $strObj->plural( $counter, $word, $pluralSuffix, $singularSuffix );

 $result = $strObj->prompt( $prompt, $editMatch, $errMsg, $default, @exitStr );

 $result = $strObj->untaint( $taintedText, $untaintPattern );

=head1 DESCRIPTION

This class provides some miscellaneous string functions not
explicitly provided in Perl.

=head2 Constructor

=over 4

=item new

Instantiate a new object of this class. This is not necessary as all 
methods in this class work identically as B<class> or B<object> methods.

 use PTools::String;

 $result = PTools::String->initialCaps( $textString );        # class method

 $strObj = new PTools::String;
 $result = $strObj->initialCaps( $textString );       # object method

=back

=head2 Methods

=over 4

=item addCommasToNumber ( BigNumber [, ForceDecimal ] )

Create syntactically correct numbers by inserting commas.
This method works with both integers and floating point values,
and also adds commas to numbers within character strings.

 $result = $strObj->addCommasToNumber( 1234567890 );

 $result = $strObj->addCommasToNumber( "Up by 4567.89%" );

To force the result to be returned as a decimal number,
even when the B<BigNumber> is an integer, pass any non-null
value as the B<ForceDecimal> parameter.

 $result = $strObj->addCommasToNumber( 1234567890, "Decimal" );


=item centerInBuffer ( String, BufferLength )

Center B<String> in a new string of B<BufferLength>.

 $result = $strObj->centerInBuffer( "Some text", 40 );


=item justifyRight ( String, BufferLength )

Right justify B<String> in a new string of B<BufferLength>.

 $result = $strObj->justifyRight( "Some text", 40 );


=item justifyListRight ( ArrayRef [, AddCommasFlag ] [, BufferLength ] )

Right justify a list of strings contained in B<ArrayRef>. 

If any non-null value is passed in the B<AddCommasFlag> parameter,
commas will be added, when appropriate, to any numbers found in 
strings within the list. See the B<addCommasToString> method, above, 
for details on adding commas to numbers.

If no B<BufferLength> is provided, the length of the longest
string contained in the B<ArrayRef> is used. When adding commas,
the length is calculated after commas, if any, are inserted.

 $arrayRef = ["10752734", "2512.05%", "72230 bytes used", "32767")];

 $strObj->justifyRight( $arrayRef );

Note that the contents of the $arrayRef is modified in this operation.

=item initialCaps ( String )

Shift the first letter of each word in B<String> to upper case.

 $result = $strObj->initialCaps( "bob m. smith, jr." );


=item stripExtraWhiteSpace ( String )

Remove leading and trailing white space from B<String>.

 $result = $strObj->stripExtraWhiteSpace( "  Some text  " );


=item stripLeftWhiteSpace ( String )

Remove leading white space from B<String>.

 $result = $strObj->stripLeftWhiteSpace( "  Some text  " );


=item stripRightWhiteSpace ( String )

Remove trailing white space from B<String>.

 $result = $strObj->stripRightWhiteSpace( "  Some text  " );


=item zero ( Value [, DefaultWhenUndef ] )

Since ("0" eq "") in Perl, and we so often need to code around this
fact, we can handle this once and for all with the B<zero> method.

Many Perl programmers eventually become familiar with following syntax.

  $value = $someStringValue ||"";
  $value = $maybeZeroValue  ||"0";

However, the above is often a bit I<too> simplistic.
Now we can get return values of "$value" OR "" OR "0" OR "undef".

  $value = $self->zeroString( $maybeZeroValue );

And we can also determine a new default for "undef" strings.

  $value = $self->zeroString( $maybeUndefValue, "0" );


=item plural ( Counter, Word, PluralSuffix [, SingularSuffix ] )

Create syntactically correct results, given an arbitrary counter value.

 $descrepencies = $strObj->plural( $error, "Descrepenc","ies","y" );
 $warnings      = $strObj->plural( $warn,  "Warning","s" );

 print "  Found $error $descrepencies\n";
 print "  Found $warn $warnings\n";


=item prompt ( Prompt, [ EditMatch [, ErrMsg ]] [, Default ] [, ExitStrList ] )

Write B<Prompt> text on STDOUT and read a line of input from STDIN.
This method handles Ctrl-D and E<lt>nullE<gt> input.

Optionally this method can perform text matching edits on the input.

=over 4

=item Prompt

A text string used to prompt the user for input. This is 
displayed on STDOUT.

=item EditMatch

A Perl match test used to edit the user's input. If match fails,
user is re-prompted for input.

=item ErrMsg

A text string used as a "hint" displayed if the B<EditMatch> fails.

=item Default

A text string used as a default value if the user enters nothing.

=item ExitStrList

A list of zero or more strings that, when entered by the user,
will terminate prompts for data entry. Defaults are B<//> and B</>.
The actual B<ExitString> entered by the user is returned as the result
to the calling module.

=back

Examples:

 $strUtil= "PTools::String";
 $uname  = $strUtil->prompt("  User name: ", "^([a-z])\\w{0,7}\$"     );
 $empno  = $strUtil->prompt(" Emp Number: ", "^(\\d{1,8}|N\\d{1,7})\$");
 $telnet = $strUtil->prompt(" Emp Telnet: ", "^(|\\d{3}-\\d{4})\$"    );
 $email  = $strUtil->prompt("     E-Mail: ", ""                       );
 $uid    = $strUtil->prompt("     UserID: ", "^\\d{1,5}\$"            );
 $gid    = $strUtil->prompt("    GroupID: ", "^\\d{1,5}\$"            );

Notice that "" will pass edit for both 'telnet' and 'email' variables.
However, if a value IS entered for 'telnet' it must match the pattern.

=item isTainted ( String )

Test a string variable for 'taintedness.'

=over 4

=item String

A string variable.

=back

Example:

 if ( PTools::String->isTainted( $text ) ) { ... }


=item detaint ( TaintedString [, AllowedChars ] )

=item untaint ( TaintedString [, AllowedChars ] )

Untaint a text string.

=over 4

=item TaintedString

A string containing 'tainted' text.

=item AllowedChars

An optional string of chars used to 'untaint' the B<TaintedString> string.
This string defaults to the '- a-zA-Z0-9_.@' characters. This string can 
not contain '.*' and, if these characters are found, the default string 
is used instead.

Any character in the B<TaintedString> not found in the B<AllowedChars> is
converted into the underscore ('_') character.

=back

Example:

 $text = String->untaint( $text );

=back


=head1 AUTHOR

Chris Cobb [no dot spam at ccobb dot net]

=head1 COPYRIGHT

Copyright (c) 2002-2007 by Chris Cobb. All rights reserved.
This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
