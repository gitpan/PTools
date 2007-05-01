# -*- Perl -*-
#
# File:  PTools/Proc/Backtick.pm
# Desc:  Simple OO interface to system commands
# Date:  Mon Apr 02 14:30:00 PDT 2001
# Stat:  Production
# Usage:
#        $commandRef = run PTools::Proc::Backtick("/bin/echo","echo this");
#        ($stat,$err)= $commandRef->status;
#        $commandOut = $commandRef->result;

package PTools::Proc::Backtick;
use strict;
use warnings;

our $PACK    = __PACKAGE__;
our $VERSION = '0.03';
our @ISA     = qw();

#use PTools::Proc::Status;    # (not needed here)


sub new { return bless {}, ref($_[0])||$_[0]; }

sub run 
{   my($self,$cmd,@args) = @_;

    ref $self or $self = new $PACK;

    chomp( $self->{result} = `$cmd @args 2>&1` );

    $self->setErr( ($? ? ($?,$self->{result}) : (0,"")) );

    return( $self,$self->{status},$self->{error} ) if wantarray;
    return $self;
}

sub result { return $_[0]->{'result'};         }
sub grep   { grep(/$_[1]/, $_[0]->{'result'}); }   # (method unused/untested)
sub match  { $_[0]->{'result'} =~ /$_[1]/;     }   # (method unused/untested)
sub setErr { $_[0]->{status} = $_[1] || 0; $_[0]->{error} = $_[2] || "";  }
sub status { return ($_[0]->{status}, $_[0]->{error});                    }
sub stat   { ( wantarray ? ($_[0]->{error}||"") : ($_[0]->{status} ||0) ) }
sub err    { return($_[0]->{error}||"")                                   }
#_________________________
1; # Required by require()

=head1 NAME

PTools::Proc::Backtick - Simple OO interface to system commands

=head1 VERSION

This document describes version 0.03, released Feb 15, 2003.

=head1 SYNOPSIS

     $cmdObj = run PTools::Proc::Backtick("/bin/echo","echo this");

     ($stat,$err)= $cmdObj->status();

 or  ($stat,$err,$cmdObj) = run PTools::Proc::Backtick( "grep", "foo", $fileName );

     $commandOut = $cmdObj->result();

 or  $stat  = $cmdObj->stat();     # status number returned in scalar context
     ($err) = $cmdObj->stat();     # error message returned in array context

     ($err) = $cmdObj->err();

=head1 DESCRIPTION

A simple object oriented interface to Perl's B<backtick> functionality.

=head2 Constructor

=over 4

=item new

The B<new> method is optional. The B<run> method will also return a
newly constructed object.

=back


=head2 Methods

=over 4

=item run ( Command [, Args ] )

Run a system command via Perl's B<backtick> functionality.

=over 4

=item Command

Specify the system command which is to be run.

=item Args

Supply any additional command-line parameter(s) for the system command.

=back

See Synopsis section for examples.


=item result

Collect any output resulting from the execution of B<Command>. This
will contain results from both STDOUT and STDERR.


=item status

=item stat

=item err

Collect the status resulting from the execution of B<Command>. When
the status code is non-zero, an error message is also returned.
See Synopsis section for examples.

=back


=head1 INHERITANCE

None currently.

=head1 SEE ALSO

See L<PTools::Proc::Status>.

=head1 AUTHOR

Chris Cobb [no dot spam at ccobb dot net]

=head1 COPYRIGHT

Copyright (c) 2002-2007 by Chris Cobb. All rights reserved.
This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
