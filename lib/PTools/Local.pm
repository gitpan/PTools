# -*- Perl -*-
#
# File:  PTools::Local.pm
# Desc:  Application class for Local and Global variable definitions
# Date:  Tue Mar 23 14:58:51 1999
# Stat:  Production
# Note:  The order of BEGINs, variable definitions and method
#        definitions is very important here. Caveat programmer.
#
package PTools::Local;
 # When this package is "Global::$appDir" or when Global.pm is in app_libdir
 # the next 11 lines (up to and including "use lib") should be comments.
 use File::Basename;
 my($locLib,$top,$app,$lib);
 BEGIN {   # This works on many systems. See "www.ccobb.net/ptools/"
 if (!$ENV{'PTOOLS_TOPDIR'} || $ENV{'PTOOLS_APPDIR'}) {
     (my $x,$locLib) = fileparse( $INC{"PTools/Local.pm"} );
     ($app,$top)     = fileparse( $locLib );             chop($top);
     ($lib,$top)     = fileparse( $top    );             chop($top);
     ($app,$top)     = fileparse( $top    );             chop($top);
     $ENV{'PTOOLS_TOPDIR'} ||= $top; $ENV{'PTOOLS_APPDIR'} ||= $app;
 } } #--------------------------------------------------------------
 use lib "$ENV{'PTOOLS_TOPDIR'}/global/lib";   # Where is Global.pm?
 use PTools::Global 0.24;                      # Set global vars first
 use strict qw( vars subs );                   # no strict "refs";
#$^W=0;

 my($PACK,$applib,$apputl,$appDir,$appPath,$parent);
 my($global,$appName,$appDesc,$appVers,$appAcro);

BEGIN {
 #
 # Define application specific names here. Add other application
 # variables to the CUSTOM APPLICATION GLOBALS section, below.
 #
 $appName = "User Command Daemon";                     # Appliaction Name
 $appDesc = "SSL-based Persistent Session Server";     # Application Description
 $appVers = "1.00";                                    # Application Version
 $appAcro = "UCD";                                     # Acronym or Abbrev.
 #______________________________________________________
 # "appDir" must be the application's directory name under PTOOLS_TOPDIR
 # so this must be hard-coded when this package is Global::<module>

 $global  = "PTools::Global";

 $PACK = __PACKAGE__;
 ${"$PACK"."::VERSION"} = '0.10';              # NOT Applic. version
 @{"$PACK"."::ISA"}     = ( $global );         # Inherit from PTools::Global

 $appDir = $ENV{'PTOOLS_APPDIR'};
 $app    = uc $appDir;
 $app   =~ s/\W//og;                           # Strip non-alphanumeric
#___________________________________________________________________________
# Reset Global:: variables - designed for persistent FastCGI scripts.
# The resetVariables method must reside within the above BEGIN block.
#
sub resetAppVariables { $_[0]->resetVariables("appOnly"); }

sub resetVariables {
  #
  # If we have any param here, only reset APP_ vars.
  #
  $_[1] and $PACK->SUPER::resetVariables($app);        # Reset only APP_ globals
  $_[1]  or $PACK->SUPER::resetVariables;              # Reset all global vars

  # Descriptions for this application 
  ${$global ."::${app}_NAME"}   = $appName;
  ${$global ."::${app}_DESC"}   = $appDesc;
  ${$global ."::${app}_VERSION"}= $appVers;
  ${$global ."::${app}_ACRONYM"}= $appAcro;

  # Quo Vadimus?
  $Global::GLOBAL_TOPDIR or $Global::GLOBAL_TOPDIR = "$ENV{'PTOOLS_TOPDIR'}";
  $appPath= "$Global::GLOBAL_TOPDIR/$appDir";
 ($parent)= $Global::GLOBAL_TOPDIR =~ m#/(\w*)$#o;     # Last element of TOPDIR

  # Directories for this application 
  ${$global ."::${app}_TOPDIR"} =  $Global::GLOBAL_TOPDIR;  # Same as Global.pm
  ${$global ."::${app}_DIR"}    =  $appDir;                 # Last elem in path
  ${$global ."::${app}_PATH"}   =  $appPath;                # Full path to app
  ${$global ."::${app}_BINDIR"} = "$appPath/bin";           # Binary files
  ${$global ."::${app}_BINUTL"} = "$appPath/bin/util";      # Binary utilities
  ${$global ."::${app}_CFGDIR"} = "$appPath/conf";          # Config files
  ${$global ."::${app}_DATDIR"} = "$appPath/data";          # Data subdirs
  ${$global ."::${app}_LOGDIR"} = "$appPath/data/logs";     # Log subdirs
  ${$global ."::${app}_QUEDIR"} = "$appPath/data/queue";    # Data queues
  ${$global ."::${app}_TMPDIR"} = "$appPath/data/tmp";      # Temp files
  ${$global ."::${app}_DOCDIR"} = "$appPath/doc";           # Private docs
  ${$global ."::${app}_LIBDIR"} = "$appPath/lib";           # Library files
  ${$global ."::${app}_LIBUTL"} = "$appPath/lib/util";      # Library utils
  ${$global ."::${app}_MANDIR"} = "$appPath/man";           # Manual pages
  ${$global ."::${app}_SRCDIR"} = "$appPath/src";           # Source: Bin&CGI
  ${$global ."::${app}_SRCUTL"} = "$appPath/src/util";      # Source: Bin&CGI
  ${$global ."::${app}_CGIDIR"} = "$appPath/webcgi";        # CGI subdirs
  ${$global ."::${app}_CGIUTL"} = "$appPath/webcgi/util";   # CGI utils
  ${$global ."::${app}_WEBDOC"} = "$appPath/webdoc";        # Public docs
  ${$global ."::${app}_IMGDIR"} = "$appPath/webdoc/images"; # Web images
  # XML and DTD specifications
  ${$global ."::${app}_XMLDIR"} = "$appPath/data/xml";      # XML files
  ${$global ."::${app}_DTDDIR"} = "$appPath/webdoc/DTD";    # DTD specs
  # CGI- and Webdoc-relative URLs, and misc. vars
  ${$global ."::${app}_CGIURL"} = "/cgi-bin/$parent/$appDir";
  ${$global ."::${app}_WEBURL"} = "/$parent/$appDir";
  ${$global ."::${app}_IMGURL"} = "/$parent/$appDir/images";
  ${$global ."::${app}_DTDURL"} = "/$parent/$appDir/DTD";
  ${$global ."::${app}_BGCOLOR"}= "#eeeeee";              # CGI form background
  ${$global ."::${app}_HEADING"}= "";                     # Header flag
  ${$global ."::${app}_VERBOSE"}= 9999;                   # Verbose by default
  ${$global ."::${app}_DEBUG"}  = 0;                      # No debug by default

  # Set up default log files used by "writeLog" method, below
  ${$global ."::${app}_DEBUGLOG"}= ${$global ."::${app}_LOGDIR"}."/debug.log";
  ${$global ."::${app}_LOGFILE"} = ${$global ."::${app}_LOGDIR"}."/$appDir.log";

  $applib = ${$global ."::${app}_LIBDIR"};
  $apputl = ${$global ."::${app}_LIBUTL"};
  #___________________________________________________
  # ADD ANY CUSTOM APPLICATION GLOBALS BELOW THIS LINE

  # Test effective UID and set a safe PATH environment (see Global.pm, too)
# $> eq "0" and $ENV{'PATH'}    = '/usr/bin:/usr/sbin:/new/path';
# $> eq "0"  or $ENV{'PATH'}    = '/usr/bin:/usr/sbin:/new/path:.';

# ${$global ."::${app}_MISC"}   = ${$global ."::${app}_DATDIR"} . "/misc";
 
  # ADD ANY CUSTOM APPLICATION GLOBALS ABOVE THIS LINE
  #___________________________________________________
  return;
} # End of resetVariables method


 # Must invoke "resetVariables" in BEGIN prior to re-arranging
 # the library include paths. Also, be sure to add a parameter 
 # here when this package is named "Global::$appDir". Otherwise,
 # "using" a Global::$appDir package will reset all Global:: vars.
 #
 $PACK eq "Global::$appDir" and $PACK->resetVariables("appOnly");
 $PACK eq "Global::$appDir"  or $PACK->resetVariables;

} # end of BEGIN directive


 # Now, re-arrange the library include paths to ensure
 # the proper presidence ordering (but only do this once).
 # Also, exclude "." from root's library path.
 #
 if (! $Global::GLOBAL_LIBREORDER_DONE) {
   $locLib or (my $x,$locLib)=fileparse($INC{"PTools/Local.pm"});
   $locLib =~ s#/$##;
   eval "no  lib  \".\", \"$locLib\", \"$applib\", \"$apputl\"";
   $> eq "0" and eval "use lib        \"$applib\", \"$apputl\"";
   $> eq "0"  or eval "use lib \".\", \"$applib\", \"$apputl\"";
   $Global::GLOBAL_LIBREORDER_DONE = 1;
 }
#___________________________________________________________________________
# Add an instantiator for convenience, then extend
# the Global methods for the current application
# (translate "app_" to the current app's identifier).
#
sub new { bless [], $_[0]; }


*get = \&param;                            # get/param will not "set"

sub param {
   my($self,$param) = @_;
   if ( $param =~ s/(^app_)/${app}_/io ) { # translate "app_", if necessary
       $param = uc($param);
       return ${ "$global"."::$param" };   # get current Local param
   }
   return $self->SUPER::param($param);
}


sub set {
   my($self,$param,$val) = @_;             # "env_" handled by PTools::Global
   if ( $param =~ s/(^app_)/${app}_/io ) { # translate "app_", if necessary
       $param = uc($param);
       my $prior = ${ "$global"."::$param" };    # get current Local param
       ${ "$global"."::$param" }  = $val;        # set new Local param
       return($prior);
   }
   return $self->SUPER::set($param,$val);
}

*unset = \&reset;                          # make unset equivalent to reset

sub reset {
   my($self,$param) = @_;                  # "env" handled by PTools::Global
   if ( $param =~ s/(^app_)/${app}_/io ) { # translate "app_", if necessary
       $param = uc($param);
       my $prior = ${ "$global"."::$param" };    # get current Local param
       undef ${ "$global"."::$param" };          # undef a scalar
       return($prior);
   }
   return $self->SUPER::reset($param);
}

sub path {
   my($self,$param,$seg) = @_;
   if ( $param =~ s/(^app_)/${app}_/io ) { # translate "app_", if necessary
       $param = uc($param);
       my $path = ${ "$global"."::$param" };    # get current Local param
       return( $path ."$seg" )   if ($seg =~ m#^/#);    # don't add a "/"
       return( $path ."/$seg" );                        # add a "/"
   }
   return $self->SUPER::path($param,$seg);
}

sub writeLog {
   my($self,$verbose,$logMsg,$logFile) = @_;

   my $logLevel;
   if ($verbose =~ /^D(ebug)?/i) {
     $logLevel = $self->param('app_debug');
     $logFile  = $self->param('app_debuglog') if ! $logFile;
   } else {
     $logLevel = $self->param('app_verbose');
   }
   return if ! $logLevel or $logLevel < $verbose;

   $logFile                    or  $logFile = $self->param('app_logfile');
   $logFile =~ /^app/i         and $logFile = $self->param('app_logfile');
   $logFile =~ /^(sys|global)/ and $logFile = $self->param('logfile');

   return if ! $logFile;
   return $self->SUPER::writeLog($verbose,$logMsg,$logFile);
}
#_________________________
1; # required by require()

__END__

=head1 NAME

PTools::Local - PTools Framework for Local and Global variables

=head1 VERSION

This document describes version 0.09, released Nov 12, 2002.

=head1 SYNOPSIS

     use '/opt/tools/<AppSubDir>/lib';
     use PTools::Local;

     $attrValue = PTools::Local->param( 'AttributeName' );
 or  $attrValue = PTools::Local->get( 'AttributeName' );

     PTools::Local->set( 'AttributeName', $attrValue );

     PTools::Local->reset( 'AttributeName' );

     $fullPath = PTools::Local->path( 'PathAttribute' );
 or  $fullPath = PTools::Local->path( 'PathAttribute', 'filename.ext' );
 or  $fullPath = PTools::Local->path( 'PathAttribute', 'extra/path/filename.ext' );

     PTools::Local->resetAppVariables();
     PTools::Local->resetVariables();

=head1 DESCRIPTION

This B<PTools::Local> module is a component of the I<Perl Tools Framework> 
that provides a mechanism for maintaining and resetting some or all of the
necessary 'script local' and 'application global' variables.

Using this class avoids the problem of having to pass long argument lists
to methods in modules or scripts. Neither this class, nor instances
thereof, need be passed. Simlpy 'using' this class provides access to
the local/global variable storage space.

This provides a deceptively simple mechanism that allows for mostly
'relocatable' Perl scripts. I.e., scripts that rely on the methods in
an application's B<PTools::Local> module to generate file system paths will
almost never need to change if/when they are moved to an entirely
different directory subtree (assuming, of course, that all the related
subdirectories remain in the relative position).

  use strict;           # strict and/or warnings can always go first
  use PTools::Local;    # do this before 'use'ing other applic. modules
  use lib "legacy/lib"; # modules here will be included before others
  use Whatever;         # then use whatever else your application uses

If you have other, legacy Perl library path(s) to include, you can add
them either just above or just below the B<use PTools::Local> line.
Above, and it/they will appear between app lib paths and system paths.
Below, and it/they will appear at the very top of your @INC paths.
(If it's confusing at first, try B<print PTools::Local->dump('incpaths')>
and it will soon become obvious what's happening.)

For B<completely> 'relocatable' scripts, just add the first seven lines,
below, to the very top of a Perl script. The PTools::Local class will
figure out the rest. Then, as long as a relative directory structure is 
maintained, your Perl scripts and modules can move to other locations 
without changing a thing.

  use Cwd;
  BEGIN {  # Script is relocatable. See http://ccobb.net/ptools/
    my $cwd = $1 if ( $0 =~ m#^(.*/)?.*# );  chdir( "$cwd/.." );
    my($top,$app)=($1,$2) if ( getcwd() =~ m#^(.*)(?=/)/?(.*)#);
    $ENV{'PTOOLS_TOPDIR'} = $top;  $ENV{'PTOOLS_APPDIR'} = $app;
  } #-----------------------------------------------------------
  use PTools::Local;          # PTools local/global vars/methods

  use MyMain::Module;          # then your script starts here #  
  exit( run MyMain::Module() );

If you have moved to a pure OO environment, the above nine lines
of code is a B<full and complete example> of a script. It just acts 
as an outer block to initiate the main module for some application.

 [ While this class has been stable for many years, it needed some ]
 [ fairly significant changes to make it acceptable for submittal  ]
 [ to CPAN. If you find any problems, contact the author. Thanks.  ]

=head2 Constructor

A constructor is provided for convenience; however, all methods are 
designed for use as I<class> methods.

  $local = new PTools::Local;     # constructor provided for convenience

  $local = "PTools::Local";       # (no constructor necessary)

=head2 Methods

=over 4

=item param ( AttributeName )

=item get ( AttributeName )

Retrieve the value for a currently set attribute.

     $attrValue = PTools::Local->param( 'AttributeName' );
 or  $attrValue = PTools::Local->get( 'AttributeName' );

=item set ( AttributeName, NewValue )

Set the value for either a new or currently set attribute.

     PTools::Local->set( 'AttributeName', $attrValue );

=item reset ( AttributeName )

Reset (unset) the value for currently set attribute.

     PTools::Local->reset( 'AttributeName' );

=item path ( PathAttribute [, AdditionalPath ] )

Return a 'rooted' file system path, optionally with a filename and/or
additional path segments.

     $dirPath  = PTools::Local->path( 'PathAttribute' );

 or  $fileName = PTools::Local->path( 'PathAttribute', 'filename.ext' );

 or  $fileName = PTools::Local->path( 'PathAttribute', 'extra/path/filename.ext' );

=item dump ( [ State ] )

The B<dump> method is used to display the currently defined attributes
and values. This will also show other useful B<State> information.

The B<State> value can be any or all of the following strings. The default
for this method is to show only the B<vars> (currently defined local and
global attributes and their values).

  incpath   - show current library include path(s)
  origpath  - show the original lib include path(s)
  inclib    - show full path of currently included library modules
  vars      - show all local/global attributes and their values
  env       - show all Environment Variables
  all       - show all of the above

Examples:

  print PTools::Local->dump();
  print PTools::Local->dump( "incpath" );
  print PTools::Local->dump( "incpath,inclib" );
  print PTools::Local->dump( "vars,env" );
  print PTools::Local->dump( "all" );

=item writeLog ( VerboseLevel, LogMsg [, LogFile ]  )

Append an entry to the logfile defined by the 'B<app_logFile>' attribute,
but only if the B<VerboseLevel> is greater than the value defined by
the 'B<app_verbose>' attribute. Optionally, pass the name of another
log file. A B<VerboseLevel> of B<-1> disables logging.

  PTools::Local->writeLogFile( 0, 'Almost always log at this verbose level' );

  PTools::Local->writeLogFile( 10, 'Maybe log at this verbose level' );

=item cgiRequired

This method is used with Web CGI-BIN scripts to determine whether the
script is currently running under a Web server.

  PTools::Local->cgiRequired();          # die unless running in CGI contect

Other attributes are available to determine correct actions to take.

  PTools::Local->get('nph') and print "HTTP/1.0 200 OK\n";
  PTools::Local->get('cgi') and print "Content-type: text/html\n\n";

=item resetVariables

=item resetAppVariables

These methods are invoked in I<mod_perl> or I<FastCGI> scripts to
reset all 'script local' and 'application global' variables between
iterations of a I<persistent> Perl script.

This first form is the most generally useful to reset variables.

  PTools::Local->resetVariables;

The second form is used with variations of the B<PTools::Local> module
discussed elsewhere. See the B<See Also> section for further pointers.

  PTools::Local->resetAppVariables;

B<Update>: This class does not work in a persistent B<mod_cgi>
environment. See the L<Warnings|"WARNINGS"> section, below.

=back

=head2 Application Attributes

The following attributes (or B<Variables>) are provided by the 
B<PTools::Local> module. Note that the attribute names are I<not> 
case sensitive.

Layout of B<Application specific> directories.
  
 Directory path        Variable      Description
 --------------------  --------      ----------------------------------
 tools/                APP_TOPDIR    Common subdir, could be "apps," whatever
    example1/          APP_PATH      Root for app; for dir name use APP_DIR
    *  bin/            APP_BINDIR    Scripts and binary files
       bin/util/       APP_BINUTL    Utility scripts and binary files
       conf/           APP_CFGDIR    Configuration files
       data/           APP_DATDIR    Data subdirectories
       data/logs       APP_LOGDIR    Log subdirectory
       data/queue      APP_QUEDIR    Data queues (ad hoc)
       data/tmp        APP_TMPDIR    Temporary files
       data/xml        APP_XMLDIR    XML data files
       doc/            APP_DOCDIR    Private documents
    *  lib/            APP_LIBDIR    Library files
       lib/util/       APP_LIBUTL    Library utilities
       man/            APP_MANDIR    man(n) files
       src/            APP_SRCDIR    Source for Binary files
       src/util/       APP_SRCUTL    Source for Binary utilities
       webcgi/         APP_CGIDIR    CGI subdirectories; for URL use APP_CGIURL
       webcgi/util/    APP_CGIUTL    CGI utilities
       webdoc/         APP_WEBDOC    Public documents; for URL use APP_WEBURL
       webdoc/images   APP_IMGDIR    Web images; for URL use APP_IMGURL
       webdoc/DTD      APP_DTDDIR    DTD specs; for URL use APP_DTDURL
       webdoc/index.html             Default welcome page

    * = required subdirectories ... all others are optional
	(the only required module in "lib" is "PTools::Local.pm")


=head1 INHERITANCE

This B<PTools::Local> class inherits from the B<PTools::Global> abstract 
base class.

=head1 WARNINGS

 [ While this class has been stable for many years, it needed some ]
 [ fairly significant changes to make it acceptable for submittal  ]
 [ to CPAN. If you find any problems, contact the author. Thanks.  ]

Using this PTools::Local class sets the current working directory 
to the I<parent> of where a given script is located. This is a
necessary part of a 'self-locating' Perl script.

Unfortunately, the PTools::Local class does not work well when running
in a persistent B<mod_perl> environment. The original intent was for
a copy of this class to be used within multiple different components
of a larger application. 

Running within a persistent B<mod_perl> envorionment makes this usage
impossible, as only the first script in a component that happens to 
load a copy of this class will 'win.' If/when other components attempt
to load B<their> own version of this class, the attempt will silently
fail causing a lot of subtle and not-so-subtle problems.

=head1 SEE ALSO

See L<PTools::Global>.

In addition, general documention about the Perl Tools Framework is available.

See L<http://www.ccobb.net/ptools/>.

=head1 AUTHOR

Chris Cobb [no dot spam at ccobb dot net]

=head1 COPYRIGHT

Copyright (c) 1997-2007 by Chris Cobb. All rights reserved.
This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
