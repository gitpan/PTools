# -*- Perl -*-
#
# File:  PTools/Proc/Daemonize.pm
# Desc:  Turn a script into a daemon process
# Auth:  Chris Cobb <nospamplease@ccobb.net>
# Date:  Mon Oct 25 08:44:09 2004
# Stat:  Production
#
# Abstract:
#        Simplifies the tasks necessary to turn a Perl script into a 
#        daemon process. Tasks performed can include the following.
#        .  verifying the current Uid and/or Gid
#        .  changing the current working directory
#        .  cleaning/untainting the runtime environment
#        .  redirecting standard IO file descriptors
#        .  detaching process from a terminal
#        .  writing the new PID to a log file
#        This class also includes a method to untaint a text string
#        for convienience when running scripts with the "-T" switch.
#
# See POD after the "__END__" of this module for all the details.
#

package PTools::Proc::Daemonize;
use strict;
use warnings;

our $PACK    = __PACKAGE__;
our $VERSION = '0.10';
our @ISA     = qw();

use POSIX qw( errno_h  );
use Fcntl qw( :DEFAULT );

my $DefaultPath = "/usr/bin:/usr/sbin";
my $EtcPath     = "";
my $LoadEtcPath = 0;

sub new    { bless {}, ref($_[0])||$_[0]  }   # $self is a simple hash ref.
sub set    { $_[0]->{$_[1]}=$_[2]         }   # Note that the 'param' method
sub get    { return( $_[0]->{$_[1]}||"" ) }   #    combines 'set' and 'get'
sub param  { $_[2] ? $_[0]->{$_[1]}=$_[2] : return( $_[0]->{$_[1]}||"" )  }
sub setErr { return( $_[0]->{STATUS}=$_[1]||0, $_[0]->{ERROR}=$_[2]||"" ) }
sub status { return( $_[0]->{STATUS}||0, $_[0]->{ERROR}||"" )             }
sub stat   { ( wantarray ? ($_[0]->{ERROR}||"") : ($_[0]->{STATUS} ||0) ) }
sub err    { return($_[0]->{ERROR}||"")   }

sub setIn    { $_[0]->{in}  = $_[1]   }
sub setOut   { $_[0]->{out} = $_[1]   }
sub setError { $_[0]->{err} = $_[1]   }
sub oldIn    { return( $_[0]->{in}  ) }
sub oldOut   { return( $_[0]->{out} ) }
sub oldError { return( $_[0]->{err} ) }

sub setPid { $_[0]->{pid} = $_[1]     }
sub pid    { return($_[0]->{pid}||"") }

sub defaultPath { $DefaultPath }
sub etcPath     { $EtcPath     }

*runAs = \&run;

sub run
{   my($self,$debug,$uid,$gid,$newDir,$umask,$evList,$newPath,$outFile,$pidFile) = @_;

    ref $self or $self = new $PACK;
    $self->setErr( 0,"" );

    $self->verifyProcess( $debug, $pidFile )  if $pidFile;
    return $self if $self->stat();

    $self->verifyUserGroup( $debug, $uid, $gid );

    $self->changeWorkingDir( $debug, $newDir )    if $newDir;

    $self->setUmask( $debug, $umask );

    $self->untaintEnv( $debug, $evList );

    $self->resetPath( $debug, $newPath );

    $self->redirectIO( $debug, $outFile );

    $self->detachSession( $debug );               # PRIOR to 'writePidToFile'

    $self->writePidToFile( $debug, $pidFile );    # AFTER 'detachSession'

    return $self;
}

sub import
{   my($class,@args) = @_;

    # Usage:   use PTools::Proc::Daemonize qw( /etc/path );
    #    or    use PTools::Proc::Daemonize qw( LoadEtcPath );

    return unless (@args);
    $LoadEtcPath = 1  if ($args[0] =~ m#^((Load|/)?Etc(/)?Path)$#i);
    return;
}

sub verifyUserGroup
{   my($self,$debug, $uid,$gid) = @_;

    return unless (defined($uid) and length($uid));
    return unless (defined($gid) and length($gid));

    $debug and print "DEBUG: $PACK: verify running as uid='$uid, gid='$gid'.\n";

    my $err;
    if (length($uid) and $uid != $<) {
	$err = "user: ". getpwuid( $uid );
    }
    if (length($gid) and $gid != $() {
	$err .= ", " if $err;
	$err .= "group: ". getgrgid( $gid );
    }
    $err and die "\nError: expected to be run by $err\n";

    # Set Effective Uid/Gid to match Real, if they don't already

    if (($> != $<) or ($) != $()) {
	$debug and print "DEBUG: $PACK: set Effective uid/gid to match Real.\n";
	$) = $gid;
	$> = $uid;
    }

    return;
}

sub changeWorkingDir
{   my($self,$debug, $newDir) = @_;

    $newDir ||= "/";

    $debug and print "DEBUG: $PACK: changing working directory to '$newDir'.\n";

    chdir("$newDir") || die "$PACK: Can't chdir to '$newDir': $!";
    return;
}

sub redirectIO
{   my($self,$debug, $outFile) = @_;

    if ($debug) {              ## Allow for a "Debug" flag here.
	print "DEBUG: $PACK: skipping 'IO redirection': 'Debug' is set.\n";
	return;
    }

    # Since a daemon detaches from terminal I/O we need to make sure
    # STDIN, STDOUT and STDERR are all redirected to a file handle.
    # Don't simply close the original file handles, as this strategy
    # may confise subprocesses that expect the standard file handles.

    if ($outFile) {
	$self->createFile( $outFile );
    } else {
	$outFile ||= "/dev/null";
    }

    if ( -f $outFile ) {
	open(STDOUT, ">>$outFile") || die "$PACK: Can't redirect 'STDOUT' to '$outFile': $!";
    } else {
	open(STDOUT, "> $outFile") || die "$PACK: Can't redirect 'STDOUT' to '$outFile': $!";
    }
    open(STDIN,  "</dev/null") || die "$PACK: Can't redirect 'STDIN' from '/dev/null': $!";
    open(STDERR, ">&STDOUT")   || die "$PACK: Can't redirect 'STDERR' (dup to STDOUT): $!";

    select STDERR;  $| = 1;    # unbuffer STDERR
    select STDOUT;  $| = 1;    # unbuffer STDOUT

    return;
}

sub setUmask
{   my($self,$debug, $umask) = @_;

    $debug and print "DEBUG: $PACK: setting umask.\n";

    #______________________________________________________
    # Set the file/directory creation permissions mask

    $umask ||= 022;
    umask( $umask );

    return;
}

sub untaintEnv
{   my($self,$debug, $evList) = @_;

    $debug and print "DEBUG: $PACK: cleaning environment vars.\n";

    #______________________________________________________
    # This will 'UnTaint' the environment via the $ENV{} hash

    foreach my $key (keys %ENV) {
	if ( (ref($evList) eq "ARRAY") and (grep(/^$key$/, @$evList)) ) {
	    $debug and print "DEBUG: -- no reset for '$key'\n";
	    next;
	}
	delete $ENV{$key};
    }
    return;
}

#-----------------------------------------------------------------------
# Include this for convenience, since we're thinking about 'untainting'
# Usage:
#   $text = $daemon->untaintString( $text [, $allowedCharList ] );
#
# Any character not in the "$allowedCharList" becomes an underscore ("_").
# The default "$allowedCharList" includes those characters identified in
# "The WWW Security FAQ" with the addition of the space (" ") character.
# An expanded set of allowed characters is available for use when the
# situation dictates. Use with care! (See also RFC1738.)

my $AllowedChars  = '- a-zA-Z0-9_.@';               # default allowed chars
my $DangerousChars= $AllowedChars .'~":;?!@#$%^&*()+=,<>{}[]|\\t\\n\\'. "`'";

*allChars     = \&dangerousChars;
*untaintChars = \&allowedChars;
*untaintText  = \&untaintString;

sub allowedChars   { return $AllowedChars    }      # default allowed chars
sub dangerousChars { return $DangerousChars  }      # non-ctrl chars, tab, nl

sub untaintString
{   my($class, $text, $allowedChars) = @_;

    $allowedChars ||= $AllowedChars;                # default allowed chars

    $text =~ s/[^$allowedChars]/_/go;               # replace disallowed chars
    $text =~ m/(.*)/;                               # untaint using a match
    return $1;                                      # return untainted match
}
#-----------------------------------------------------------------------

my $EtcPathLoaded = 0;

sub resetPath
{   my($self,$debug, $newPath) = @_;

    $debug and print "DEBUG: $PACK: resetting PATH var.\n";
    #______________________________________________________
    # The default is an 'UnTainted' $PATH

    $newPath ||= $DefaultPath;
    $newPath ||= "/usr/bin:/usr/ccs/bin:/usr/contrib/bin";

    if ($LoadEtcPath and ! $EtcPathLoaded) {
	local(*IN);
	if (open(IN,"</etc/PATH")) {
	    $EtcPath = <IN>;
	    if ($EtcPath =~ /^(.*)$/) { $EtcPath = $1 }
	    close(IN) || die "$PACK: Can't close '/etc/PATH': $!";
	}
	$EtcPathLoaded = 1;

	# Emulate "/etc/profile" to ensure PATH includs "/usr/bin"
	# If /usr/bin is present in /etc/PATH then $DefaultPath is set
	# to the contents of /etc/PATH. Otherwise, add the contents of
	# /etc/PATH to the end of the $DefaultPath definition above.

	if ($EtcPath =~ m#(^|:)/usr/bin(:|$)#) {
	    $DefaultPath = "$EtcPath";
	} elsif ($EtcPath) {
	    $DefaultPath .= ":$EtcPath";
	}
    }

    # And again ... ensure PATH includs "/usr/bin"

    if ($LoadEtcPath) {
	$ENV{PATH} = $DefaultPath;
    } elsif ($newPath =~ m#(^|:)/usr/bin(:|$)#) {
	$ENV{PATH} = $newPath;
    } elsif ($DefaultPath =~ m#(^|:)/usr/bin(:|$)#) {
	$debug and print "DEBUG: $PACK: NOTE that PATH is reset to default.\n";
	$ENV{PATH} = "$newPath:$DefaultPath";
    } else {
	$ENV{PATH} = "/usr/bin:$newPath:$DefaultPath";
    }

    return;
}

sub detachSession
{   my($self, $debug) = @_;

    if ($debug) {              ## Allow for a "Debug" flag here.
	print "DEBUG: $PACK: skipping 'session detach': 'Debug' is set.\n";
	return;
    }

    my $pid = fork;
    defined $pid || die "$PACK: Fork failed: $!";

    $pid > 0 and exit(0);      ## Parent process bails out here.
    $pid == 0 || die "$PACK: Could not fork daemon process.";
                               ## Child process continues here.
    $self->setPid( $$ );

    # For systems that don't support the "setsid()" call, see
    # the "Proc::Daemon" CPAN module.

    POSIX::setsid();

    sub TIOCNOTTY { return 0x20007471 }
    local(*TTY);
    if (open (TTY, "</dev/tty")) {
	ioctl(TTY, TIOCNOTTY,0);
	close(TTY);
    }

    return;
}

sub verifyProcess
{   my($self, $debug, $pidFile ) = @_;

    # If we are using a "$pidFile" for this daemon, ensure that
    # any PID therein does NOT match a currently active process.

    return unless $pidFile and -r $pidFile;

    ## $debug and print "DEBUG: $PACK: check for PID in '$pidFile'\n";

    local(*IN);
    open(IN, "<$pidFile") || die "$PACK: Can't open '$pidFile': $!";
    my $processId = <IN>  || die "$PACK: Can't read '$pidFile': $!";
    close(IN)             || die "$PACK: Can't close '$pidFile': $!";

    chomp( $processId );
    $processId = $self->untaintString( $processId );

    ## $debug and print "DEBUG: $PACK: found: pid='$processId'\n";

    return unless ($processId and $processId =~ /^\d+$/);

    $debug and print "DEBUG: $PACK: check for running proc: pid='$processId'\n";

    my $procRunning = CORE::kill( 0, $processId );
    my($err);

    if ($! == EPERM) {         # Not owner: expected error
	## $debug and print "DEBUG: $PACK: kill 0 $processId = 'EPERM'\n";
	$procRunning = 1;      # (allows running as non-root user)

    } elsif ($! == ESRCH)  {   # No process: expected error
	## $debug and print "DEBUG: $PACK: kill 0 $processId = 'ESRCH'\n";
    } elsif ($! == EBADF)  {   # Bad filenum: possible error (why?)
	## $debug and print "DEBUG: $PACK: kill 0 $processId = 'EBADF'\n";
    } elsif ($! == ECHILD) {   # No child procs: possible error (why?)
	## $debug and print "DEBUG: $PACK: kill 0 $processId = 'ECHLD'\n";

    } elsif ( $! ) {           # Other: unexpected error
	## $debug and print "DEBUG: $PACK: kill 0 $processId = '$!'\n";
	$err = sprintf(
	    "kill 0 failed for pid='%d': %s (err:%d)\n",
	    $processId, $!, $!
	);
    }

    if ($procRunning) {
	## $debug and print "DEBUG: $PACK: $processId 'IS RUNNING'\n";
	$err ||= "daemon process already running (pid $processId)";
	return $self->setErr(-1, $err);
    } else {
	## $debug and print "DEBUG: $PACK: $processId 'NOT running'\n";
    }
    return;
}

sub writePidToFile
{   my($self, $debug, $pidFile ) = @_;

    return unless $pidFile;

    $debug and print "DEBUG: $PACK: saving PID to '$pidFile'\n";

    $self->createFile( $pidFile );

    local(*OUT);
    open(OUT, ">$pidFile") || die "$PACK: Can't open '$pidFile': $!";
    print OUT "$$\n"       || die "$PACK: Can't write '$pidFile': $!";
    close(OUT)             || die "$PACK: Can't close '$pidFile': $!"|

    return;
}

sub createFile
{   my($self,$fileName,$umask) = @_;

    my $oldUmask;
    $oldUmask = umask( 0 ) unless $umask;   # save current umask; reset to 0

    if (! -f $fileName) {
	my $newUmask = $umask || '644';
	local(*FH);
       	sysopen(FH, $fileName, O_WRONLY|O_CREAT, oct($newUmask))
	    || die "$PACK: Can't sysopen '$fileName': $!";
	close(FH)               || die "$PACK: Can't close '$fileName': $!";

    }
    umask( (umask() & 0) | $oldUmask )  if $oldUmask;  # restore prior umask

  # my($mode,$uid,$gid) = ( 0664, $<, $(, );
  # chmod( $mode, $fileName)    || die "Can't chmod($mode, $fileName): $!";
  # chown($uid,$gid,$fileName)  || die "Can't chown($uid,$gid, $fileName): $!";
  # umask( (umask() & 0) | $oldUmask );     # restore prior umask

    return;
}
#_________________________
1; # Required by require()

__END__

=head1 NAME

PTools::Proc::Daemonize - Turn a script into a daemon process

=head1 VERSION

This document describes version 0.09, released April, 2006.

=head1 SYNOPSIS

    use PTools::Proc::Daemonize;

 or use PTools::Proc::Daemonize qw( LoadEtcPath );

    run PTools::Proc::Daemonize();

 or run PTools::Proc::Daemonize( Debug, UID, GID, WorkingDir, Umask, EvListRef, PATH, OutFile, PidFile );

 or $daemon = new PTools::Proc::Daemonize;

    $daemon->verifyProcess( Debug, PidFile );
    die $daemon->err()  if $daemon->stat();     # Exit if a daemon is running

    $daemon->verifyUserGroup( Debug, UID, GID );

    $daemon->changeWorkingDir( Debug, WorkingDir );

    $daemon->setUmask( Debug, Umask );

    $daemon->untaintEnv( Debug, EvListRef );

    $daemon->resetPath( Debug, PATH );

    $daemon->redirectIO( Debug, OutFile );      # Skipped when Debug true

    $daemon->detachSession( Debug );            # Skipped when Debug true

    $daemon->writePidToFile( Debug, PidFile );

The following methods are provided for convenience when running Perl 
scripts that use the '-T' switch (highly recommended for scripts that 
will become daemon processes).

    $allow = $daemon->allowedChars();

    $text = $daemon->untaintString( $text, $allow );


=head1 DESCRIPTION

This class simplifies all of the tasks necessary to turn a Perl script into
a daemon process. Tasks performed can include any or all of the following.

 .  verifying the current Uid and/or Gid
 .  changing the current working directory
 .  setting a new file/dir creation Umask value
 .  cleaning/untainting the runtime environment
 .  resetting the PATH environment variable
 .  redirecting standard IO file descriptors
 .  detaching process from a terminal
 .  writing the new PID to a log file

When used with a 'B<LoadEtcPath>' parameter, the 'B<untaintEnvironment>'
method will process the '/etc/PATH' file as done in '/etc/profile'.

=head2 Constructor

=over 4

=item run ( Debug, UID, GID, WorkingDir, Umask, EvListRef, PATH, OutFile, PidFile )

The B<run> method can be used to accomplish any or all of the necessary
tasks described in the L<Description|description> section, above. As an
alternative, each of the specific tasks can be accomplished separately,
by making explicit calls to each of the various methods described below.
Each of the arguments described here are the same for the various methods.

Note that 'B<runAs>' is a synonymous name for this method, and all
arguments to the methods are optional. 

Also note that when using the B<run> method there is no default for
the B<WorkingDir> argument. However, when explicitly calling the
B<changeWorkingDir> method, described below, the B</> (system root) 
directory is the default. And, when using a B<PidFile> for a given
daemon, the B<run> method will verify the contents of the named file 
does not match an active process ID (if so, an error condition is set).

=over 4

=item Debug

Any non-zero value enables B<Debug> mode. When set, the current standard
IO is not redirected, and the session is not detached from a controlling
terminal.

=item UID

A Unix account B<User Id>, expected to be an integer between 0 and 65535.

=item GID

A Unix account B<Group Id>, expected to be an integer between 0 and 65535.

=item WorkingDir

A path that will become the script's new B<Working Directory>. Default is '/'.

=item Umask

A numeric value that will become the script's new file creation B<Umask> value.
Default is '0'.

=item EvListRef

This parameter must be a reference to a list of environment variable names.
Any listed EV names will B<not> be removed from the script's environment.

=item Path

A colon separated string of directory paths that will become the script's new
B<Search Path>. Default is '/usr/bin:/usr/sbin'.

=item Outfile

A path that will become the script's new STDOUT and STDERR output file.
Default is '/dev/null'.

=item PidFile

A path to which the script's new <Process ID> will be written.
Default is to not save the new PID.

=back

=back

=head2 Methods

=over 4

=item verifyProcess ( [ Debug ], PidFile )

Verify that the process identification number contained in the named
B<PidFile> does B<not> match a currently active process. If the 'pid'
B<does> match, an error condition is set.

Argument values are the same as described for the L<run|run> method, above.


=item verifyUserGroup ( [ Debug ] [, UID ] [, GID ] )

Verify that the script is currently running as one or both
of the specified B<UserID> or B<GroupID>.

Argument values are the same as described for the L<run|run> method, above.


=item changeWorkingDir ( [ Debug [, WorkingDir ] )

Change the script's current working directory to a new B<WorkingDir> path.

Argument values are the same as described for the L<run|run> method, above.


=item setUmask ( [ Debug ] [, Umask] )

Set a new file and directory creation B<umask> value

Argument values are the same as described for the L<run|run> method, above.


=item untaintEnv ( [ Debug ] [, EvListRef ])

Clean up the script's current environment settings.

An optional B<EvListRef> argument can be passed to retain named
Environment Variables. This argument is expected to be a reference
to an array of variable names.

Argument values are the same as described for the L<run|run> method, above.


=item resetPath ( [ Debug ] [, PATH ] )

Set a new value for the B<PATH> environment variable.

When this class is used with the 'B</etc/path>' parameter, this
method will process the 'etc/PATH' file as done in '/etc/profile'.

Argument values are the same as described for the L<run|run> method, above.


=item redirectIO ( [ Debug ] [, OutFile ] )

Redirect the script's standard IO, including STDIN, STDOUT and STDERR
to a new B<OutFile>. Redirection is skipped when B<Debug> true.

Argument values are the same as described for the L<run|run> method, above.


=item detachSession ( [ Debug ] )

The script is not detached from the session when when B<Debug> true.

Argument value is the same as described for the L<run|run> method, above.


=item writePidToFile ( [ Debug ] [, PidFile ] )

After the current process is I<forked> into a new sesison, write the
new Process ID into the specified B<PidFile>.

Argument values are the same as described for the L<run|run> method, above.


=item untaintString ( Text [, AllowedChars ] )

=item untaintText ( Text [, AllowedChars ] )

This method is provided for convenience when running a Perl script with 
the '-T' switch. It is highly recommended that a script which will become 
a daemon process be run in this manner. This method simplifies the process 
of 'untainting' Perl variables when necessary.

=over 4

=item Text

This parameter is a 'tainted' Perl string.

=item AllowedChars

This optional parameter is a string of allowed characters that are
retained in the B<Text> string during the 'untainting' process.
This defaults to the value returned by the B<L<allowedChars>> method.

=back

Example:

 $text = $daemon->untaintString( $text );

=item allowedChars ()

=item untaintChars ()

This method returns the default string of characters that are 
allowed (i.e., 'retained') in strings that are 'untainted' using 
the B<L<untaintString>> method. This list includes those characters 
identified in I<The WWW Security FAQ> with the addition of the space 
character  (http://www.w3.org/Security/Faq/www-security-faq.html).

 - a-zA-Z0-9_.@

This includes the characters dash, space, alpha-numerics, underscore,
dot or period, and the commercial 'at' symbol.

Example:

 $allow = $daemon->allowedChars();

 $text = $daemon->untaintString( $text, $allow );

=item allChars

=item dangerousChars

This method returns all typable 'non-control' characters including tab 
and newline. The result can then be used with the B<L<untaintString>> 
method, above, to untaint a text (scalar) variable that came from a 
'reasonably secure' source. For example, loading configuration or 
template data from an external file into a 'tainted' variable.

 - a-zA-Z0-9_.@~`'":;?!@#$%^&*()+=,<>{}[]|\\t\\n\\

B<Warning: Under NO circumstances should this list of characters be
used to untaint text entered by the user of a particular script or
Web form. Ignoring this warning might result in unauthorized access 
to your computer system.>

Example:

 $danger = $daemon->dangerousChars();

 $text = $daemon->untaintString( $text, $danger );

=back


=head1 INHERITANCE

None currently.

=head1 SEE ALSO

See L<POSIX> and L<Fcntl>.

=head1 AUTHOR

Chris Cobb, E<lt>nospamplease@ccobb.netE<gt>

=head1 COPYRIGHT

Copyright (c) 2004-2007 by Chris Cobb. All rights reserved.
This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
