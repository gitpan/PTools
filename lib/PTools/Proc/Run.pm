# -*- Perl -*-
#
# File:  PTools/Proc/Run.pm
# Desc:  Run a process with error checking
# Date:  Wed Sep 22 14:01:28 2004
# Stat:  Production
#
# Note:  Runs a command using Perl's "open()" via the pipe ("|") character.
#        For use when it's not appropriate to simply start a child process
#        using Perl's `backtick` operator. Here we explicitly open a Perl
#        system command pipe and test for multiple failure modes.
#
# Synopsis:
#        use PTools::Proc::Run;
#        $cmd = "PTools::Proc::Run";
#   -or- $cmd = new PTools::Proc::Run;
#
#        ($stat,$result) = run $cmd echo => 'foo';
#        $stat and die $result;

package PTools::Proc::Run;
use 5.006;
use strict;
use warnings;

our $PACK    = __PACKAGE__;
our $VERSION = '0.01';
our @ISA     = qw( );

# For convenience only. All other methods are intended as
# 'class' methods. This allows for object methods as well.
#
sub new { bless {}, ref($_[0])||$_[0]  }

* runCmd = \&run;
* exec   = \&run;

sub run
{   my($class,$cmd,@args) = @_;

    my($result,$stat,$sig,$shellStatus) = ("",0,0,"0");
    local(*CMD);

    # FIX: allow redirection into a log file
    #      for both OUT and ERR (separately??)

  # if (! (my $chpid = open(CMD, "exec $cmd @args |")) ) {

    if (! (my $chpid = open(CMD, "exec $cmd @args 2>&1 |")) ) {
        ($stat,$result) = (-1, "fork failed: $!");
	## warn("=" x 20 ."ERROR: $result");

    } else {
        my(@result) = <CMD>;             # ensure the pipe is emptied here
        $result = (@result ? join("",@result) : "");
        chomp($result);

        if (! close(CMD) ) {
            if ($!) {
                $stat = -1;
                $result and $result .= "\n";
                $result .= "Error: command close() failed: $!";
		warn ("=" x 20 ."ERROR: $result");
            }
            if ($?) {
                ($stat,$sig,$shellStatus) = $class->rcAnalysis( $? );
            }
        }
    }
    ## warn ("=" x 20 ." STAT: $shellStatus");

    return( $stat, $result, $shellStatus, $!, $? );
}

sub rcAnalysis
{   my($class,$rc) = @_;
    #
    # Modified somewhat from the example in "Programming Perl", 2ed.,
    # by Larry Wall, et. al, Chap 3, pg. 230 ("system" function call)
    # "$shellStatus" will mimic what the various shells are doing.
    #
    my($stat,$sig,$shellStatus);

    $rc = $? unless (defined $rc);

    $rc &= 0xffff;

    if ($rc == 0) {
        ($stat,$sig,$shellStatus) = (0,0,"0");
    } elsif ($rc & 0xff) {
        $rc &= 0xff;
        ($stat,$sig,$shellStatus) = ($rc,$rc,"signal $rc");
        if ($rc & 0x80) {
            $rc &= ~0x80;
            $sig = $rc;
            $shellStatus = "signal $sig (core dumped)";
        }
    } else {
       $rc >>= 8;
       ($stat,$sig,$shellStatus) = ($rc,0,$rc); # no signal, just exit status
    }
    # Note: $shellStatus is the closest value as the Shell's $?
    return($stat,$sig,$shellStatus);
}
#_________________________
1; # Required by require()

__END__

=head1 NAME

PTools::Proc::Run - Run a process with error checking

=head1 VERSION


