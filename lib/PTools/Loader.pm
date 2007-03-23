# -*- Perl -*-
#
# File:  PTools/Loader.pm
# Desc:  Include a Perl module via "use", "require" or "eval" and detect errs.
#        Emits HTML when run via a Web CGI script; emits plain text otherwise.
# Date:  Wed Nov 22 12:50:00 PST 2000
# Date:  Thu Aug 16 10:06:58 PDT 2001  - added "eval" method <cobb@cup.hp.com>
# Stat:  Production
# Note:  Perl's "$@" variable contains the first error detected 
#        when using or requiring a module, not the 1st warning.
#
# Synopsis:
#     use PTools::Loader qw(generror);         ## Loader will abort on errors
#
#     $loader = new PTools::Loader;
#     $loader = "PTools::Loader";
#
#     $loader->req("Date::Format");               # require module
#     $loader->use("CGI");                        # use module
#     $loader->use("CGI", "qw(:standard)");       # use module w/params 
#     $loader->eval("filename");                  # eval contents of "filename"
#     $loader->ver("5.004");                      # check Perl level
#
#     $loader->inc("req", "LWP");                 # require module
#     $loader->inc("use", "Date::Format");        # use module
#     $loader->inc("use", "CGI ':standard'");     # use module w/params 
#
#     @result = $loader->eval("filename");        # eval contents of "filename"
#     $codeRef= $loader->codeRef( @result );      # extract code ref from 'eval'
#
# or  use PTools::Loader;                     ## Loader won't abort on errors
#
#     $loader = new PTools::Loader;
#     $loader = "PTools::Loader";
#
#     $error = $loader->req("Forms::MainMenu");   # these first three exmamples
#     $error = $loader->use("CGI","2.56");        #   will attempt to load the
#     $error = $loader->eval("filename");         #   file and return any error
#
#     @result = $loader->eval("filename");        # eval contents of "filename"
#     $codeRef= $loader->codeRef( @result );      # extract code ref from 'eval'
#
#     (@err) = $loader->use("Roman");             # collect all info on error
#     @err and $self->cleanup;  # for example,   # delay abort to run cleanup
#     $loader->abort( @err );                     # cause abort IFF any error
#
#     ($perlError, $loadMode, $moduleName,       # collect all info on error
#      $callingPackage, $callingFileName,
#      $callingFileLineNumber)            = $loader->use("Mail::Mailer");
#
#     ($perlError, $loadMode, $moduleName,
#      $callingPackage, $callingFileName,
#      $callingFileLineNumber, $codeRef)  = $loader->eval("Mail::Mailer");
#

package PTools::Loader;
 use strict;

 my $PACK = __PACKAGE__;
 use vars qw ( $VERSION @ISA $GENERROR );
 $VERSION = '0.12';
#@ISA     = qw( );
 $GENERROR= '0';

#use Generror;        # additional class to generate error messages not used

sub use { 
  my($class,$module,@args) = @_;
  my(@result) = $class->_include("use",$module,@args);
  return(@result) if wantarray;
  return($result[0]);
}

sub req { 
  my($class,$module) = @_;
  my(@result) = $class->_include("require",$module);
  return(@result) if wantarray;
  return($result[0]);
}

sub eval {
  my($class,$file) = @_;
  my(@result) = $class->_eval($file);
  return(@result) if wantarray;
  return($result[0]);
}

# Since all of these functions are "class" methods, add a method
# to extract the "codeRef" from a previous "eval." The ref is now
# appended to the list returned by the "eval" method.

sub codeRef {
  my($class,@result) = @_;
  my $codeRef = $result[$#result];
  return( ref $codeRef ? $codeRef : undef );
}

sub inc { 
  my($class,$mode,$module,@args) = @_;
  my(@result) = "";
  (@result) = $class->_include("use",$module,@args) if $mode eq "use";
  (@result) = $class->_include("require",$module)   if $mode =~ /req(uire)?/;
  (@result) = $class->_eval($module)                if $mode eq "eval";
  return(@result) if wantarray;
  return($result[0]);
}

# Define some method aliases. Note that defining a 'require' 
# method will cause Perl to emit "Ambiguous call" warnings.

   *include  = \&inc;

   *perlver  = \&req;
   *version  = \&req;
   *ver      = \&req;

   *err      = \&abort;
   *gen      = \&abort;

sub abort {
  my($class,$err,$mode,$module,$pack,$file,$line) = @_;

  $err or return;            $mode  ||= "{unknown}";
  $module ||= "{unknown}";   $pack  ||= "{unknown}";
  $file   ||= "{unknown}";   $line  ||= "{unknown}";

  # Touch up the $@ string a wee bit before the abort.
  # Remember to format <html> -or- plain text here.

  my $cgi_bin = $ENV{'HTTP_USER_AGENT'} ? 1 : 0;
  my($br,$pp) = ( $cgi_bin ? ("<br>","<p>") : ("\n","\n\n") );
  my $message = 
     "Failed to '$mode $module' in $pack at line $line in file $br $file";

  $err =~ s/ \(\@INC ([^)]*)\)//;
  $cgi_bin and $err =~ s/</&lt;/g;
  $cgi_bin and $err =~ s/>/&gt;/g;

  $err =~ s/(only version \d+\.?\d*\.?\d* )/$1 $br   /;
  $err =~ s/(, stopped at )/, stopped $br   at /;
  $err =~ s/\nBEGIN failed--compilation/$br  /g;

  die ("$message $pp $err");                 # when Generror not available

  #Generror->sysHeader("$message $pp   $err");
  # nothing returns ... script is aborted in Generror module.
}

sub noabort  { $GENERROR = '0' }
sub doabort  { $GENERROR = '1' }

sub generror
{   my($class,$mode) = @_;

    my $tmp = $GENERROR;                     # save original setting

    ($mode and length($mode))
	and $GENERROR = "$mode";             # reset, if argument passed

    return $tmp;                             # return original setting
}

#____________________________________________________________
# Private methods.

sub import {
  my($class,@args) = @_;
  $args[0] and $args[0] =~ /generror/i ? $GENERROR = '1' : "";
}

sub _include {                          # private method--note "caller(1)"
  my($class,$mode,$module,@args) = @_;
  my($pack,$file,$line,$subname,$hasargs,$wantarray) = caller(1);

  $mode and $module or return("");
  CORE::eval "$mode $module @args";

  @args and $module = "$module @args";
  no strict "refs";
  $@ and ${"$PACK"."::GENERROR"} 
     and $class->abort($@,$mode,$module,$pack,$file,$line);

  return($@,$mode,$module,$pack,$file,$line);
}

sub _eval {                             # private method--note "caller(1)"
  my($class,$fileName) = @_;
  my($pack,$file,$line,$subname,$hasargs,$wantarray) = caller(1);
  #
  # Note: a code ref is returned as the last parameter in 
  # the "@results" list. Use "codeRef" method to extract.
  #
  local(*IN);
  my $codeRef;
  if (open(IN,"<$fileName")) {
    my $code;
    while( <IN> ) {
       last if m#^(__END__)$#;
       $code .= $_;
    }
    close(IN);

    if ($code =~ /^(.*)$/s) { $code = $1;     # untaint $code
    } else { die "Error: Invalid characters in 'code' string."; }

    $codeRef = CORE::eval $code;
  }
  my $err = $! if $!;
  $err or $err = $@;
  #
  # Warn: return "$codeRef" as the last element or change
  # the "codeRef" method to return the correct element.
  #
  no strict "refs";
  $err and ${"$PACK"."::GENERROR"} 
       and $class->abort($err,"eval",$fileName,$pack,$file,$line,$codeRef);

  return($err,"eval",$fileName,$pack,$file,$line,$codeRef);
}
#_________________________
1; # Required by require()

__END__

=head1 NAME

PTools::Loader - Demand load Perl modules at run-time w/error checking.

=head1 VERSION

This document describes version 0.11, released October, 2004.

=head1 SYNOPSIS

By default B<PTools::Loader> will not abort on errors. Add string I<generror>
in B<use> statement to cause PTools::Loader to abort when errors are detected.

     use PTools::Loader qw(generror);        ## Loader will abort on errors

     $loader = new PTools::Loader;
     $loader = "PTools::Loader";

     $loader->req("Date::Format");               # require module
     $loader->use("CGI");                        # use module
     $loader->use("CGI", "qw(:standard)");       # use module w/params 
     $loader->eval("filename");                  # eval contents of "filename"
     $loader->ver("5.004");                      # check Perl level

     @result = $loader->eval("filename");        # eval contents of "filename"
     $codeRef= $loader->codeRef( @result );      # extract code ref from 'eval'

     $loader->inc("req", "LWP");                 # require module
     $loader->inc("use", "Date::Format");        # use module
     $loader->inc("use", "CGI ':standard'");     # use module w/params 

By default B<PTools::Loader> will not abort on errors, and the B<abort>
method must be called. This will simply return when no errors occurred.

 or  use PTools::Loader;                      ## Loader won't abort on errors

     $loader = new PTools::Loader;
     $loader = "PTools::Loader";

     $error = $loader->req("Forms::MainMenu");   # these first three exmamples
     $error = $loader->use("CGI","2.56");        #   will attempt to load the
     $error = $loader->eval("filename");         #   file and return any error

     @result = $loader->eval("filename");        # eval contents of "filename"
     $codeRef= $loader->codeRef( @result );      # extract code ref from 'eval'

     (@err) = $loader->use("Roman");             # collect all info on error
     @err and $self->cleanup;  # for example,   # delay abort to run cleanup
     $loader->abort( @err );                     # cause abort IFF any error

     ($perlError, $loadMode, $moduleName,       # collect all info on error
      $callingPackage, $callingFileName,
      $callingFileLineNumber)            = $loader->use("Mail::Mailer");

     ($perlError, $loadMode, $moduleName,
      $callingPackage, $callingFileName,
      $callingFileLineNumber, $codeRef)  = $loader->eval("Mail::Mailer");

=head1 DESCRIPTION

Include a Perl module via "use", "require" or "eval" and detect errs.

=head2 Constructor

None. All functions in this module are implemented as B<class> methods.

=head2 Methods

=over 4

=item use ( Module [, @args ] )

Include the specified Perl B<Module> via the B<use> function. Any
additional arguments are appended directly to the B<use> function.

Examples:

 $loader->use("CGI");

 $loader->use("CGI", "qw(:standard)");

 $error = $loader->use("CGI","2.56");

 (@err) = $loader->use("Roman");
  @err and $self->cleanup;
  $loader->abort( @err );            # only aborts if error occurred

=item req ( Module )

Include the specified Perl B<Module> via the B<require> function.

Examples:

 $loader->inc("req", "LWP");

 $error = $loader->req("Forms::MainMenu");

=item eval ( File )

Include the specified Perl B<File> via the B<eval> function.

Examples:

 $loader->eval( $filename );

 $error = $loader->eval( $filename );

=item codeRef ( @params )

As this module only contains I<class> methods, the B<codeRef>
method is available to extract the code reference from the
results of any prior call to the B<eval> method.

 use $loader;

 @results = $loader->eval( $fileName );

 $loader->abort( @results );

 $codeRef = $loader->codeRef( @results );

The above complete example shows one way to ensure the B<eval>
call was successful. The call to B<abort> will only terminate
the script when errors were detected during the eval.

If the I<fileName> contains a fully defined package, it is not
necessary to obtain the B<codeRef> as the resulting code will
be available using its I<package name space> as soon as the
B<eval> method completes successfully.

Also see notes on the I<generror> option to the B<use> statement,
above, and discussion of the B<abort> method, below.


=item inc ( Mode, Module [, Args ] )

Include the specified Perl B<Module> based on the B<Mode>.

=over 4

=item Mode

The B<Mode> parameter must be one of B<use> or B<req>.

=item Module

The B<Module> parameter is the name of the Perl module, as above.

=item Args

The B<Args> parameter are optional parms passed to the Perl module, as above.

=back

Examples:

 $loader->inc("req", "LWP");                 # require module

 $loader->inc("use", "Date::Format");        # use module

 $loader->inc("use", "CGI ':standard'");     # use module w/params 

=item ver

Ensure the required version of the Perl intepreter is currently running.

Example:

 $loader->ver("5.004");

=item abort ( @params )

=item abort ( Err, Mode, Module, Pack, File, Line )

The B<abort> method is available to defer aborting the script when errors
are detected. This is useful when a "cleanup" step is necessary, for example.

Example:

 (@err) = $loader->use("Roman");             # collect all info on error
 @err and $self->cleanup;                   # delay abort to run cleanup
 $loader->abort( @err );                     # cause abort IFF any error

The parameter list passed to the abort method is designed to be the same
as returned from any of the B<use>, B<req>, B<eval> or B<inc> methods.

During the abort, this method emits HTML when run via a Web CGI script. 
Otherwise it emits plain text.

=back

=head1 INHERITANCE

No classes currently inherit from this class.

=head1 AUTHOR

Chris Cobb, E<lt>nospamplease@ccobb.netE<gt>

=head1 COPYRIGHT

Copyright (c) 2002-2007 by Chris Cobb. All rights reserved.
This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
