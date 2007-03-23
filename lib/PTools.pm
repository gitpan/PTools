# -*- Perl -*-
#
# File:  PTools.pm
# Date:  Sun Mar 18 14:47:11 2007
# Desc:  Simple module to 'use' multiple PTools utility modules
#
package PTools;
use 5.006001;
use strict;
use warnings;
use Carp qw( croak );

our $PACK = "__PACKAGE__";
our $VERSION = '0.01';
our @ISA = qw();

sub import
{   my($class, @modules) = @_;

    my $package = $PACK;
    my @failed;

    foreach my $module (@modules) {
	my $code = "package $package; use PTools::$module;";
	# warn $code;
	eval($code);
	if ($@) {
	    warn $@;
	    push(@failed, $module);
	}
    }
    @failed and 
	croak "could not import qw(" . join(' ', @failed) . ") in '$PACK'";
    return;
}
#_________________________
1; # Required by require()

__END__

=head1 NAME

PTools - Facilitates 'using' PTools utility modules

=head1 SYNOPSIS

 use PTools qw( Counter Options Proc::Daemonize );

=head1 DESCRIPTION

PTools is a collection of Perl Tools for Perl Tool Developers. These
meta-tools have evolved over the years to simplify the normal, everyday
types of tasks that most scripts, at some point, need to address.

PTools includes a couple of classes that implement a flexible, multi-tier
library heirarchy for larger applications that makes the development
and evolution of modules and apps a lot easier. These also allow for
completely relocatable Perl apps without modification to directory
paths, and allow close integration with Web CGI and/or document URLs. 

PTools includes a class that allows module developers to create
'extendible' methods. This allows users of their modules to choose
what class will actually get invoked when a method is called. What's
this good for? Deciding during run-time what class is used to 'sort()' 
data in a given application, or deciding what class is used to
'lock()' and 'unlock()' a resource to prevent concurrency issues.

PTools also includes such things as 
a module to handle the counters in an application (with nice formatting);
a module to easily turn a script into a daemon process; 
a module to temporarialy redirect stdout and/or stderr to a string or an array;
OO interfaces to Getopt::Long, Date::Format and Date::Parse 
(with some added value).

B<Note>: This module is just used to simplify loading other PTools modules.
This class is not very useful on its own, and is not even necessary, as 
the other PTools classes load quite nicely all by themselves.

=head1 SEE ALSO

For details of the various PTools modules, refer to the man
page for that module.

 PTools::Global           together, these first two modules are used to
 PTools::Local            define a flexible development environment

 PTools::Counter          -  handle all the counters in an application
 PTools::Date::Format     -  oo wrapper for the original, with some extras
 PTools::Date::Parse      -  oo wrapper for the original
 PTools::Debug            -  add debug levels to a script
 PTools::Extender         -  create 'extendible' methods within a class
 PTools::List             -  collect lists of things identified by a string
 PTools::Loader           -  demand-load Perl modules at run-time
 PTools::Options          -  oo wrapper for Getopt::Long, with added value
 PTools::Passwd           -  generate and validate Unix style passwords
 PTools::Proc::Backtick   -  oo interface to Perl's `backtick` operator
 PTools::Proc::Daemonize  -  turn a script into a long-running daemon process
 PTools::Proc::Run        -  run a child process, with extra error checks
 PTools::RedirectIO       -  temporarially redirect stdout and/or stderr
 PTools::String           -  misc string functions not availible in Perl
 PTools::Time::Elapsed    -  turn start/end times into a readable string
 PTools::Verbose          -  add verbose levels to a script
 PTools::WordWrap         -  reformat a text string

=head1 AUTHOR

Chris Cobb, E<lt>NoSpamPlease@ccobb.netE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Chris Cobb
This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut
