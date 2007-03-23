# -*- Perl -*-
#
# File:  PTools/WordWrap.pm
# Desc:  Format text strings
# Date:  Wed Oct 16 15:20:15 PDT 1996
# Mods:  Fri Jul 19 01:31:57 PDT 2002
# Lang:  Perl
# Stat:  Production
#
# Synopsis:
#
#     use PTools::WordWrap;
#     
#     $textBlock = PTools::WordWrap->parse( 72, $textBlock );
#
# 
# Abstract:
#
#   "Given an arbitrary string ... look for long lines ^M"
#    ^                                         ^        ^
#    curPos                              nextPos        crlfPos
#
#  Where:
#    curPos = current position in string; this index "leap frogs"
#             over the "crlfPos" index as string segments are
#             processed
#
#   nextPos = one of a)  71 chars out from start of string
#                 or b)  71 chars out from last CRLF found
#                 or c)  71 chars out from a CRLF we just inserted
#                 or d)  at the next CRLF position in the text
#                 or e)  at the end position of the string
#
#             If there are more than 70 chars between this
#             index and the "curPos" index, then we need to
#             insert one line break in the current segment.
#
#             Also, we may need to insert multiple line breaks
#             before we reach the current value of "crlfPos"index.
#
#   crlfPos = either a)  the position of next CRLF characters
#                 or b)  end position of the string
#
#  Note that some text may have both Carriage Return and Newline
#  characters at the end of each line and other text may just have
#  Newline characters; this routine handles both cases.
#
#  And, of course, this routine is designed so that any text can be
#  sent back through this routine at any time. After the first time
#  through, no further changes will be made (unless the text changes
#  or the specified margin is less than in the previous iteration).
#

package PTools::WordWrap;
use strict;

use vars qw( $VERSION );
$VERSION = 0.04;

*wrapLongLines = \&parse;                  # retain original method name

sub parse {
  my($class)      = shift;
  my($hardMargin) = shift;                 # If < 10 will be set to 70
  my($text)       = shift;                 # Text to be parsed

  #___________________________________
  # Initialize some vars
  #
  my($CRLF,$softMargin,$crlfPos,$curPos,$nextPos,$strLen);
  my($done,$check,$pos);

# $CRLF = "\r\n";         # (each of          # Carriage Return and Newline
# $CRLF = "\cM\n";        # these are         # Carriage Return and Newline
  $CRLF = "\015\012";     # equivalent)       # Carriage Return and Newline

  $crlfPos= index($text,$CRLF,0);             # Do we have "\r\n" chars?
  if ($crlfPos == -1) {                       # if none found then just
     $CRLF = "\012";                          # look for "\n" chars.
  } else {
  }

  if ($hardMargin < 10) {
     $hardMargin= 70;                         # Hard margin
  }
  $softMargin = $hardMargin + 1;              # Soft margin
  $curPos = 0;                                # Start at beginning of string
  $nextPos=$softMargin;                       # and look for long lines

  $strLen = length($text);                    # Check to make sure that
  if ($strLen < $hardMargin) {                # we even need to process
    return($text);                            # this string.
  }

  $crlfPos= index($text,$CRLF,$curPos);       # Find first CRLF in string
  if ($crlfPos == -1) {                       # if none, then use
     $crlfPos = $strLen;                      # the end of the string
  }

  if ($nextPos > $crlfPos) {                  # Do a sanity check and adjust
     $nextPos=$crlfPos;                       # if first line is a short one
  }
  #___________________________________
  # Loop through entire text block
  #
  $done="";
  while (!$done) {

#$check = $nextPos - $curPos;
#printf(" DEBUG: crlfPos = %d \t curPos = %d \t nextPos = %d \t (diff = %s)\n",
#                  $crlfPos,        $curPos,      $nextPos,       $check );
    #___________________________________
    # Loop through current section of text
    # up to the next CRLF character adding
    # line breaks as necessary
    #
    $check = $nextPos - $curPos;                  # Do we have a long line??

    while ($check > $hardMargin) {                # Yup ...

       $pos = _replaceSpace($hardMargin,$curPos,
			    \$text,$CRLF);        # Force a CR/LF

       $curPos = $pos + 1;                        # Set up for another loop if
       $nextPos= $curPos + $softMargin;           # line is still too long ...

       if ($nextPos > $crlfPos) {
          $check = 0;                             # All done w/this "paragraph"
       } else {
          $check = $nextPos - $curPos;            # Line is still too long!
       }
    }

    #___________________________________
    # Find next occurance of CRLF if any
    #
    $curPos = $crlfPos + 1;                       # Leap frog to next segment
    $crlfPos= index($text,$CRLF,$curPos);         # and find next existing CRLF

    if ($crlfPos == -1 && $curPos < $strLen) {    # Short segment w/out CRLF so
       $crlfPos = $strLen;                        # go to end of string (EOS)

    } elsif ($crlfPos == -1) {                    # We're outta' here!
       $done = "True";
    }

    #___________________________________
    # Set up for the next paragraph
    #
    $nextPos= $curPos  + $softMargin;             # Mark off the next segment
    if ($nextPos > $crlfPos) {                    # which cannot be longer than
       $nextPos= $crlfPos;                        # the next CRLF char (or EOS)
    }
  }
  return($text);                                  # We're outta' here.
}

  #___________________________________________________
  #
  # Look backwards through the text string starting at position 
  # "$start" and ending with position "$end" ... replace the first 
  # space found with a CR/LF and return the position in the string.
  #
  sub _replaceSpace {

    my($hardMargin,$end,$text,$CRLF) = @_;
    my($start) = $end + $hardMargin;

    while ($start > $end) {
      if (substr($$text,$start,1) eq " ") {
         substr($$text,$start,1) = "$CRLF";        # Retain space & add CR/LF
         return($start);                          # and return the offset
      }
      $start--;
    }
    return($end);                                 # No replacement done.
  }
#_________________________
1; # Required by require()

__END__

=head1 NAME

PTools::WordWrap - Format text strings

=head1 VERSION

=head1 AUTHOR

Chris Cobb, E<lt>nospamplease@ccobb.netE<gt>
