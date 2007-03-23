# -*- Perl -*-
#
# File:  PTools::RedirectIO
# Desc:  Generic IO handler for process sessions
# Date:  Wed Feb 02 17:03:35 2005
# Stat:  Prototype
#
# Abstract:
#    Provides a mechanism that will interrupt all output from
#    'print' and 'printf' calls and stuff the output into a string
#    or list variable. When output is collected, the 'resetStdout()' 
#    method can be called which returns all collected output.
#
# Synopsis:
#    use PTools::RedirectIO;
#    $io = "PTools::RedirectIO";
#
#    #  *STDOUT
#
#    $io->redirectStdout();
#    $io->redirectStdout()  unless $io->outIsRedirected();
#
#    print "foo\n";
#    printf("%s", "foo\n");
#
#    $stdout = $io->resetStdout();
#
#    #  *STDERR
#
#    $io->redirectStderr();
#    $io->redirectStderr()  unless $io->errIsRedirected();
#
#    print "foo\n";
#    printf("%s", "foo\n");
#
#    $stderr = $io->resetStderr();
#

package PTools::RedirectIO;
use strict;
use warnings;

my($OrigOut,$TempOut,$OutIsRedirected) = (undef,undef,0);
my($OrigErr,$TempErr,$ErrIsRedirected) = (undef,undef,0);

#-----------------------------------------------------------------------
sub outIsRedirected { $OutIsRedirected }

*redirectStdout = \&redirect_stdout;

sub redirect_stdout
{   my($class) = @_;

    if ($OutIsRedirected) {    # Oops! already redirected
	$TempOut = undef;      # start with a "clean slate"
	untie *STDOUT;
    }
    $OrigOut = *STDOUT;

    # Overrides Perl's "print" and "printf" but not "write".
    # Note: 'OutputToString' class is defined, below.
    #
    $TempOut = tie *STDOUT, 'OutputToString';

    $OutIsRedirected = 1;
    return;
}

*resetStdout  = \&reset_stdout;

sub reset_stdout
{   my($class) = @_;

    untie *STDOUT;
    my $stdout = $$TempOut;        # note scalar reference here
    $TempOut = undef;              # don't forget memory cleanup
    $OutIsRedirected = 0;
    return $stdout;
}

#-----------------------------------------------------------------------
sub errIsRedirected { $ErrIsRedirected }

*redirectStderr = \&redirect_stderr;

sub redirect_stderr
{   my($class) = @_;

    if ($ErrIsRedirected) {    # Oops! already redirected
	$TempErr = undef;      # start with a "clean slate"
	untie *STDERR;
    }
    $OrigErr = *STDERR;

    # Overrides Perl's "warn" "print STDERR" and "printf STDERR".
    # Note: 'OutputToString' class is defined, below.
    #
    $TempErr = tie *STDERR, 'OutputToString';

    $ErrIsRedirected = 1;
    return;
}

*resetStderr  = \&reset_stderr;

sub reset_stderr
{   my($class) = @_;

    untie *STDERR;
    my $stderr = $$TempErr;        # note scalar reference here
    $TempErr = undef;              # don't forget memory cleanup
    $ErrIsRedirected = 0;
    return $stderr;
}
#-----------------------------------------------------------------------

package OutputToString;  # Send FILE output to a string
sub TIEHANDLE { my $str; bless \$str, ref($_[0])||$_[0] }  # instantiate/tie
sub PRINT     { ${$_[0]} .= ( $_[1] ||'' )              }  # override 'print'
sub PRINTF    { ${$_[0]} .= sprintf $_[1],$_[2]         }  # override 'printf'
sub UNTIE 
{   my ($self,$count) = @_;
    # Suppress warning: can't undef $TempOut until *after* untie.
    # warn "untie: $count inner references still exist" if $count;
}

package OutputToArray;  # Send FILE output to an array
sub TIEHANDLE { bless [], ref($_[0])||$_[0]          }  # instantiate on 'tie'
sub PRINT     { push  @{$_[0]}, $_[1]                }  # override 'print'
sub PRINTF    { push  @{$_[0]}, sprintf $_[1],$_[2]  }  # override 'printf'
sub WRITE     { print "WRITE CALLED...NOT\n"         }  # this does NOT work
#_________________________
1; # Required by require()

__END__

=head1 NAME

PTools::RedirectIO - Generic IO handler for process sessions

=head1 VERSION


