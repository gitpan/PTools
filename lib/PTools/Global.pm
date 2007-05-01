# -*- Perl -*-
#
# File:  PTools/Global.pm
# Desc:  Base class for Global variable defs. Used in ALL MODULES.
# Date:  Tue Mar 23 14:58:51 1999
# Stat:  Production
# Note:  The order of BEGINs, variable definitions and method
#        definitions is very important here. Caveat programmer.
#
# WARN:  Avoid the temptation to unset "$^W" in this module. It will
#        allow sloppy programming to creep into any app built under
#        the PTools framework, and cause a lot of rework later on.
#
package PTools::Global;

 use File::Basename;
 BEGIN {   # This works on many systems. See "www.ccobb.net/ptools/"
 if (!$ENV{'PTOOLS_TOPDIR'}) {
     my($x,$globLib) = fileparse( $INC{"PTools/Global.pm"} ); ##__PACKAGE__
     ($x,$top)     = fileparse( $globLib );              chop($top);
     ($x,$top)     = fileparse( $top    );               chop($top);
     ($x,$top)     = fileparse( $top    );               chop($top);
     $ENV{'PTOOLS_TOPDIR'} = $top;    # No 'PTOOLS_APPDIR' in Global
 } } #--------------------------------------------------------------

 use strict "subs";                               # no strict "refs","vars";
 my($PACK,$app,$appDir,$appPath,$parent,$HLF,$SLF,$parlVer,$archName,$archLib);

BEGIN {
 $PACK = __PACKAGE__;
 ##$^W=0;                    # Unsetting "$^W" here is a *really* bad idea.
#___________________________________________________________________________
# Reset Global:: variables - designed for persistent FastCGI scripts.
# The resetVariables method must reside within the above BEGIN block.
#
sub resetVariables {
  #
  # If no parameter was passed to this method unset all Global:: variables.
  # Otherwise, only unset the Global:: vars for the specified application.
  # Ignore hash vars here or we will undefine inheritence relationships.
  #
  if ($_[1]) {
    my $app = $_[1];
    map { if (/^${app}_/) { undef ${"${PACK}::$_"}; undef @{"${PACK}::$_"};
          } } keys %{"${PACK}::"};
    return;
  } else {
    map { undef ${"${PACK}::$_"}; undef @{"${PACK}::$_"}; } keys %{"${PACK}::"};
  }
  ${"$PACK"."::VERSION"} = '0.24';                   # Set version after undefs

  $appDir  = "global";                               # This should not change!
  $app     = uc $appDir;
  ${"$PACK"."::GLOBAL_TOPDIR"} = $ENV{'PTOOLS_TOPDIR'};    # Quo Vaids?
  $appPath = ${"$PACK"."::GLOBAL_TOPDIR"} ."/$appDir";
 ($parent) = ${"$PACK"."::GLOBAL_TOPDIR"} =~ m#/(\w*)$#o;

  # Descriptions for this application 
  ${"$PACK"."::GLOBAL_NAME"}   = "PerlTools Environment";
  ${"$PACK"."::GLOBAL_DESC"}   = "PerlTools: A Perl Application Environment";
  ${"$PACK"."::GLOBAL_VERSION"}= '0.04';             # Note: PTools version!
  ${"$PACK"."::GLOBAL_ACRONYM"}= "PTools";

  ${"$PACK"."::GLOBAL_DIR"}    =  $appDir;                 # Last elem in path
  ${"$PACK"."::GLOBAL_PATH"}   =  $appPath;                # Full path: TOPDIR/global
  ${"$PACK"."::GLOBAL_BINDIR"} = "$appPath/bin";           # Binary files
  ${"$PACK"."::GLOBAL_BINUTL"} = "$appPath/bin/util";      # Binary utils
  ${"$PACK"."::GLOBAL_CFGDIR"} = "$appPath/conf";          # Config files
  ${"$PACK"."::GLOBAL_DATDIR"} = "$appPath/data";          # Data subdirs
  ${"$PACK"."::GLOBAL_LOGDIR"} = "$appPath/data/logs";     # Log subdirs
  ${"$PACK"."::GLOBAL_QUEDIR"} = "$appPath/data/queue";    # Data queues
  ${"$PACK"."::GLOBAL_TMPDIR"} = "$appPath/data/tmp";      # Temp files
  ${"$PACK"."::GLOBAL_DOCDIR"} = "$appPath/doc";           # Private docs
  ${"$PACK"."::GLOBAL_LIBDIR"} = "$appPath/lib";           # Library files
  ${"$PACK"."::GLOBAL_LIBUTL"} = "$appPath/lib/util";      # Library utils
  ${"$PACK"."::GLOBAL_MANDIR"} = "$appPath/man";           # Manual pages
  ${"$PACK"."::GLOBAL_SRCDIR"} = "$appPath/src";           # Source: Bin & CGI
  ${"$PACK"."::GLOBAL_SRCUTL"} = "$appPath/src/util";      # Source: Bin & CGI
  ${"$PACK"."::GLOBAL_CGIDIR"} = "$appPath/webcgi";        # CGI subdirs
  ${"$PACK"."::GLOBAL_CGIUTL"} = "$appPath/webcgi/util";   # CGI utils
  ${"$PACK"."::GLOBAL_WEBDOC"} = "$appPath/webdoc";        # Public docs
  ${"$PACK"."::GLOBAL_IMGDIR"} = "$appPath/webdoc/images"; # Web images
  # XML- and DTD-related directories
  ${"$PACK"."::GLOBAL_XMLDIR"} = "$appPath/data/xml/global";    # XML files
  ${"$PACK"."::GLOBAL_DTDDIR"} = "$appPath/webdoc/DTD";         # DTD specs
  # CGI- and Webdoc-relative URLs, and misc. vars
  ${"$PACK"."::GLOBAL_CGIURL"} = "/cgi-bin/$parent/$appDir";    # CGI URL
  ${"$PACK"."::GLOBAL_WEBURL"} = "/$parent/$appDir";            # Web URL
  ${"$PACK"."::GLOBAL_IMGURL"} = "/$parent/$appDir/images";     # Images URL
  ${"$PACK"."::GLOBAL_DTDURL"} = "/$parent/$appDir/DTD";        # DTD URL
  ${"$PACK"."::GLOBAL_FORMHEADER"} = "";                        # Form header
  ${"$PACK"."::GLOBAL_FORMHEADERPRINTED"} = "";                 # Header flag
  ${"$PACK"."::GLOBAL_BGCOLOR"}= "#ffffff";                     # CGI background
  ${"$PACK"."::GLOBAL_OPTIONS"}= "";                            # User's options
 #${"$PACK"."::GLOBAL_CPANLIB"}= "$ENV{'PTOOLS_TOPDIR'}/cpan/lib";

  # Test effective UID and set a safe PATH environment
# $> eq "0" and $ENV{'PATH'} = '/usr/bin:/usr/sbin:/new/path';    # Root user
# $> eq "0"  or $ENV{'PATH'} = '/usr/bin:/usr/sbin:/new/path:.';  # Other user

  # Set variables for dirname(1) and basename(1) of current script
  ${"$PACK"."::GLOBAL_SCRIPTNAME"} = $0;
 (${"$PACK"."::GLOBAL_DIRNAME"}, ${"$PACK"."::GLOBAL_BASENAME"}) = ($0=~m#^(.*/)?(.*)#);
  ${"$PACK"."::GLOBAL_DIRNAME"}  or ${"$PACK"."::GLOBAL_DIRNAME"}  = ".";
  ${"$PACK"."::GLOBAL_BASENAME"} or ${"$PACK"."::GLOBAL_BASENAME"} = $0;

  # Set variables used to determine runtime context of current script
  ${"$PACK"."::GLOBAL_CGI"} = 1 if ($ENV{'HTTP_USER_AGENT'});
  ${"$PACK"."::GLOBAL_NPH"} = 1 if (${"$PACK"."::GLOBAL_BASENAME"} =~ /^nph-/);

  # Default log file
  ${"$PACK"."::GLOBAL_LOGFILE"}= ${"$PACK"."::GLOBAL_LOGDIR"} ."/system.log";

  # Used to add context-sensative line breaks to text strings:
  $HLF = (${"$PACK"."::GLOBAL_CGI"} ? "<br>\n" : "\n" );  # Hard line feed
  $SLF = (${"$PACK"."::GLOBAL_CGI"} ? " "      : "\n" );  # Soft line feed

  # my($hostname) = `hostname` =~ /([^\.]*)/;       # Too much overhead
  # chomp $hostname;                                #  to always set the
  # ${"$PACK"."::GLOBAL_HOSTNAME"}= $hostname;            #  system name?

  $main::Ok    =  $main::True  = 1;                 # some truths, and
  $main::NotOk =  $main::False = 0;                 # some falsehoods
  return;
} # End of resetVariables method

 # if a partial library path was used, strip it in "no lib" statement, below.
 #
 if ($INC{"PTools/Global.pm"} !~ m#^/#o) {
   $main::GlobalLib or (my $x,$main::GlobalLib)=fileparse($INC{"Global.pm"});
   $main::GlobalLib =~ s#/$##;
 }
 $main::GlobalLib ||= "";

 # Must invoke "resetVariables" in BEGIN prior 
 # to re-arranging the library include paths.
 #
 $PACK->resetVariables;
 
 # Finally, when including access to a "local" CPAN library tree
 # initialize the version and architecture dependent variables
 # (all the GLOBALS are omitted when using the "LocalLite" module).
 #
 use Config;
 $archName  = $Config{archname} || "";
 $archLib   = $Config{archlib}  || "";
 ($perlVer) = $archLib =~ m#lib/([^/]*)/#;
 $perlVer ||= "";

} # end of BEGIN directive


 # Now, re-arrange the library include paths to ensure the proper presidence 
 # ordering.  These next 2 lines can safely be omitted when PTools::Global is 
 # located in app_libdir.  Note "use lib" example that includes a "cpan" lib.
 #
 no  lib ${"$PACK"."::GLOBAL_LIBDIR"}, ${"$PACK"."::GLOBAL_LIBUTL"}, "$main::GlobalLib";
#use lib ${"$PACK"."::GLOBAL_LIBDIR"}, ${"$PACK"."::GLOBAL_LIBUTL"};

 use lib ${"$PACK"."::GLOBAL_LIBDIR"}, ${"$PACK"."::GLOBAL_LIBUTL"},

	 # The following add access to a "local" CPAN library tree, and
	 # assumes that the libs are installed "architecture dependent."
	 # Can be removed when not needed. ToDo: make this configurable.
	 #
         "$ENV{'PTOOLS_TOPDIR'}/cpan/lib/${perlVer}/${archName}",
         "$ENV{'PTOOLS_TOPDIR'}/cpan/lib/${perlVer}",
         "$ENV{'PTOOLS_TOPDIR'}/cpan/lib/site_perl/${perlVer}/${archName}",
         "$ENV{'PTOOLS_TOPDIR'}/cpan/lib/site_perl/${perlVer}";

       # "$ENV{'PTOOLS_TOPDIR'}/cpan/lib/site_perl";
       # ${"$PACK"."::GLOBAL_CPANLIB"};

#___________________________________________________________________________

sub new { bless [], $_[0]; }

# Allow for easy queries of variables. If not found
# in PTools::Global package, look in Environment space.
#
# Usage:
#    my $prodBinDir = param PTools::Global ('bindir');
#    my $appDatDir  = PTools::Global->param('app_datdir');  
#
#    (The string "app_" is translated by the PTools::Local class)
#
#    my $envPath    = PTools::Global->param('path');
#    my $envPath    = PTools::Global->param('env_path');
#
sub param {
  my($env) = $_[1] =~ /^env_(.*)/io;           # Forced to look in Environment?
  $env and return $ENV{uc($env)};              # ... then do so and return.

  my      $val= ${ "$PACK"."::". uc($_[1]) };            # Search Global::
  $val or $val= ${ "$PACK"."::"."GLOBAL_". uc($_[1]) };  # Search Global::GLOBAL
  $val or $val= $ENV{uc($_[1])};                         # Search Environment
  return($val);
}

*get = \&param;

sub set {
  return if ! $_[1] and $_[2];
  my $prior;
  my($env) = $_[1] =~ /^env_(.*)/io;
  if ( $env ) {
    $prior = $ENV{uc($env)};
    $ENV{uc($env)} = $_[2];
  } else {
    $prior = ${ "$PACK"."::GLOBAL_" . uc($_[1]) };    # Specify 'app_' or not
    ${ "$PACK"."::GLOBAL_" . uc($_[1]) } = $_[2];
  }
  return($prior);
}

sub reset {
  return if ! $_[1];
  my $prior;
  my($env) = $_[1] =~ /^env_(.*)/io;
  if ( $env ) {
    $prior = $ENV{uc($env)};
    delete $ENV{uc($env)};                            # delete a hash elem
  } else {
    $prior = ${ "$PACK"."::GLOBAL_" . uc($_[1]) };    # Specify 'app_' or not
    undef ${ "$PACK"."::GLOBAL_" . uc($_[1]) };       # undef a scalar
  }
  return($prior);
}

sub getDirname  { ${"$PACK"."::GLOBAL_DIRNAME"}  ||"" }
sub getBasename { ${"$PACK"."::GLOBAL_BASENAME"} ||"" } 

*getDirName    = \&getDirname;
*getBaseName   = \&getBasename;
*getHostName   = \&getHostname;
*getHostDomain = \&getDomain;
*getFQDN       = \&getFqdn;
*getHostFqdn   = \&getFqdn;
*getHostFQDN   = \&getFqdn;

sub getHostname
{   return ${"$PACK"."::GLOBAL_HOSTNAME"} if defined ${"$PACK"."::GLOBAL_HOSTNAME"};
    chomp( ${"$PACK"."::GLOBAL_HOSTNAME"} = `hostname` );

    if ( ${"$PACK"."::GLOBAL_HOSTNAME"} =~ m#^([^\.]*)\.(.+)# ) {
        ${"$PACK"."::GLOBAL_HOSTNAME"} = $1;
        ${"$PACK"."::GLOBAL_HOSTDOMAIN"} = $2;
    }
    return ${"$PACK"."::GLOBAL_HOSTNAME"};
}

sub getDomain
{   return ${"$PACK"."::GLOBAL_HOSTDOMAIN"} if defined ${"$PACK"."::GLOBAL_HOSTDOMAIN"};
    ${"$PACK"."::GLOBAL_HOSTDOMAIN"} = $_[0]->_domainLookup;
    return ${"$PACK"."::GLOBAL_HOSTDOMAIN"};
}

sub getFqdn
{   if (defined ${"$PACK"."::GLOBAL_HOSTFQDN"}) {
	wantarray or return ${"$PACK"."::GLOBAL_HOSTFQDN"};
	return( ${"$PACK"."::GLOBAL_HOSTNAME"}, ${"$PACK"."::GLOBAL_HOSTDOMAIN"} );
    }
    my($hostname, $domain)   = ( $_[0]->getHostname, $_[0]->getDomain );
    ${"$PACK"."::GLOBAL_HOSTFQDN"} = ( $domain ? $hostname .".". $domain : $hostname);
    wantarray or return ${"$PACK"."::GLOBAL_HOSTFQDN"};
    return( $hostname, $domain );
}

sub _domainLookup
{   # High overhead method. Use "domain" or "fqdn" instead,
    # as those methods cache their results for quick reuse.
    local(*IN);
    open(IN,"</etc/resolv.conf") or return "";
    my($line,$domain) = ("","");
    while (defined (my $line =<IN>) ) {
	if ( $line =~ /^domain\s+(\S+)/ ) {
	    $domain = $1;
	    last;
	}
    }
    close(IN);
    $domain ||= "_UNKNOWN_DOMAIN_";
    return $domain;
}

#
# Allow for easily extending path variables.
#
# Usage:
#    my $newDataQueue = path PTools::Global ('quedir', "newDataQueue");
#
sub path {
  my      $val = ${ "$PACK"."::" . uc($_[1]) };            # Global::
  $val or $val = ${ "$PACK"."::" ."GLOBAL_". uc($_[1]) };  # Global::GLOBAL

  if ($_[2] and $val) {              # If found, add to path when asked
     if ($_[2] =~ m#^/#) {
         $val .= "$_[2]"             # . don't add extra "/" here
     } else {
         $val .= "/$_[2]";           # . must  add extra "/" 
     }
  }
  return($val);
}

#
# Provide generic abort message for scripts that must be run via Web CGI-BIN
#
sub cgiRequired {
 ${"$PACK"."::GLOBAL_CGI"} or die "\n This script intended to be run via Web CGI\n\n";
 return;
}

#
# Provide a simple logging mechanism
#
sub writeLog {
  my($self,$verbose,$logMsg,$logFile) = @_;
  #
  # The $verbose param is handled by Local.pm.
  # LogFile fix: handle file descriptors here
  #
  $logFile or $logFile = $self->param('logfile');
  return if ! $logFile;

  local *LOG;
  open(LOG,">>$logFile") || return;
  print LOG "$logMsg\n";
  close(LOG);
  return;
}

#
# Allow for easily setting and printing form headers when 
# necessary and omit them after they've first been printed.
#
# Usage:
#    PTools::Global->setHeader("My CGI Header Text");
#    print PTools::Global->getHeader;
#
  ${"$PACK"."::GLOBAL_FORMHEADERPRINTED"} = 0;      # Initialize flag 

sub getHeader {
  my ($self,$pre,$post) = @_;
  $pre  ||= "";
  $post ||= "";
 #return if ! ${"$PACK"."::GLOBAL_CGI"};            # No headers if not running CGI
  return if ${"$PACK"."::GLOBAL_FORMHEADERPRINTED"}; # No headers if already printed
  return $self->setHeader($post)             if $pre =~ /^setHead/io;
  my $val;  
     $val .= "HTTP/1.0 200 OK\n"             if ${"$PACK"."::GLOBAL_NPH"};
     $val .= "$pre\n"                        if ${"$PACK"."::GLOBAL_CGI"} and $pre;
     $val .= "Content-type: text/html\n\n"   if ${"$PACK"."::GLOBAL_CGI"};
     $val .= '<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">' ."\n"
                                             if ${"$PACK"."::GLOBAL_CGI"};
     $val .= ${"$PACK"."::GLOBAL_FORMHEADER"} ."\n"  if ${"$PACK"."::GLOBAL_FORMHEADER"};
     $val .= "$post\n"                       if ${"$PACK"."::GLOBAL_CGI"} and $post;
  ${"$PACK"."::GLOBAL_FORMHEADERPRINTED"} = 1;     # Set flag even when not "printed"
  return($val);
}

sub setHeader {
  my ($self,$text) = @_;

  if ($text =~ /^undef$|^reset$/io) {
     ${"$PACK"."::GLOBAL_FORMHEADER"} = "";          # Reset global header value
     ${"$PACK"."::GLOBAL_FORMHEADERPRINTED"} = "";   # Reset headerprinted flag
  } else {
     ${"$PACK"."::GLOBAL_FORMHEADER"} = $text;       # Set global header value
  }
  return;
}

#
# Replace string formatting characters based on current run context.
#
sub parseText {
  my($self,$string) = @_;

  $string =~ s/{HLF}/$HLF/gio;
  $string =~ s/{SLF}/$SLF/gio;
  return $string;
}

#
# Allow for easily displaying variables during debugging.
#
# Usage:
#    print PTools::Global->dump("env");
#    print PTools::Global->dump("incLib");
#    print PTools::Global->dump("origInc");
#    print PTools::Global->dump("incPath");
#    print PTools::Global->dump("vars");
#    print PTools::Global->dump();                       # default is "vars"
#    print PTools::Global->dump("all");
#    print PTools::Global->dump("incLib,incPath");
#

*toString = \&dump;                            # toString is equivalent to dump

sub dump 
{   my($self,$arg) = @_;

    $arg ||= "";
    my $str;

    my($pack,$file,$line)=caller();
    $str .= "Content-type: text/html\n\n<pre>" if $_[0]->param('cgi'); 
    $str .= "DEBUG: ($PACK\:\:dump) self='$_[0]'\n";
    $str .= "CALLER $pack at line $line ($file)\n";

    if ($arg =~ /env|all/io) {
      $str .= "______________________________\n";
      $str .= "CURRENT ENVIRONMENT VARIABLES\n";
      foreach (sort keys %ENV) { $str .= "$_ = $ENV{$_}\n"; }
    }
    if ($arg =~ /inclib|all/io) {
      $str .= "______________________________\n";
      $str .= "CURRENTLY INCLUDED LIBRARIES\n";
      foreach (sort keys %INC) { $str .= "$_ = $INC{$_}\n"; }
    }
    if ($arg =~ /originc|all/io) {
      $str .= "______________________________\n";
      $str .= "ORIGINAL LIBRARY INCLUDE PATHS\n";
      foreach (@lib::ORIG_INC) { $str .= "$_\n"; }
    }
    if ($arg =~ /incpath|all/io) {
      $str .= "______________________________\n";
      $str .= "CURRENT LIBRARY INCLUDE PATHS\n";
      foreach (@INC) { $str .= "$_\n"; }
    }
### $str .= "DEBUG: arg = '$arg'\n";
    if ($arg =~ /^$|vars|all/io) {    # NUL param works here
      $str .= "______________________________\n";
      $str .= "CURRENT GLOBAL VARIABLES\n";
      my $name;
      foreach (sort keys %{ "${PACK}::" }) {

	# warn "DEBUG: key = '$_'\n";
	# $name = "$Global::$_";

	 next unless defined "${PACK}::$_";
         $name = "${PACK}::$_";


         $str .= "\$$name = ${ $name }\n" if defined ${ $name };
  
         if (defined @{ $name }) {
            $str .= "\@$name = \n";
	    foreach my $val (@{ $name }) {
               $str .= "   $val\n";
	    }
         }
       # if (defined %{ $name }) {
       #    $str .= "\%$name = \n";
       #    foreach my $val (sort keys %{ $name }) {
       #       $str .= "   $val => ${ $name }{$val}\n";
       #    }
       # }
      }
    }
    $str .= "______________________________\n";
    $str .= "</pre>\n" if $_[0]->param('cgi');
    return($str);
}

#_________________________
1; # required by require()

__END__

=head1 NAME

PTools::Global - PTools Framework for Local and Global variables

=head1 VERSION

This document describes version 0.18, released October, 2004.

=head1 SYNOPSIS

     use '/opt/tools/<AppSubDir>/lib';
     use PTools::Local;

     $attrValue = PTools::Local->param( 'AttributeName' );
 or  $attrValue = PTools::Local->get( 'AttributeName' );

     PTools::Local->set( 'AttributeName', $attrValue );

     PTools::Local->reset( 'AttributeName' );

     $dirPath  = PTools::Local->path( 'PathAttribute' );
 or  $fullPath = PTools::Local->path( 'PathAttribute', 'filename.ext' );
 or  $fullPath = PTools::Local->path( 'PathAttribute', 'extra/path/filename.ext' );

     PTools::Local->resetAppVariables();
     PTools::Local->resetVariables();

     $basename  = PTools::Local->getBasename();
     $dirname   = PTools::Local->getDirname();

     $hostname  = PTools::Local->getHostname();
     $domain    = PTools::Local->getDomain();
     $fqdn      = PTools::Local->getFqdn();
 or  ($host,$domain) = PTools::Local->getFqdn();

     PTools::Local->cgiRequired();      # abort w/messge if not in CGI BIN context

=head1 DESCRIPTION

This module is not intended to be used directly. It should be implicitly
used via an application's B<PTools::Local> module as shown above.

This B<PTools::Global> module is a component of the I<Perl Tools Framework> 
that provides a mechanism for maintaining and resetting some or all of the
necessary 'script local' and 'application global' variables.

This provides a deceptively simple mechanism that allows for completely
'relocatable' Perl scripts. I.e., scripts that rely on the methods in
an application's B<PTools::Local> module to generate file system paths will
almost never need to change if/when they are moved to an entirely
different directory subtree (assuming, of course, that all the related
subdirectories remain in the relative position).


=head2 Constructor

A constructor is provided for convenience; however, all methods are 
designed for use as I<class> methods.

  $localObj = new PTools::Local;


=head2 Methods

See L<PTools::Local> for a description of the available methods.

=head2 Global Attributes

The following attributes (or B<Variables>) are provided by the 
B<PTools::Global> module. Note that the attribute names are I<not> 
case sensitive.

Layout of B<GLOBAL> specific directories.
  
 Directory path        Variable      Description
 --------------------  --------      ----------------------------------
 tools/                TOPDIR        Common subdir, could be "apps," whatever
    global/            PATH          Root for global; for dir name use DIR
    *  bin/            BINDIR        Scripts and binary files
       bin/util/       BINUTL        Utility scripts and binary files
       conf/           CFGDIR        Configuration files
       data/           DATDIR        Data subdirectories
       data/logs       LOGDIR        Log subdirectory
       data/queue      QUEDIR        Data queues (ad hoc)
       data/tmp        TMPDIR        Temporary files
       data/xml        XMLDIR        XML data files
       doc/            DOCDIR        Private documents
    *  lib/            LIBDIR        Library files
       lib/util/       LIBUTL        Library utilities
       man/            MANDIR        Manual pages
       src/            SRCDIR        Source for Binary files
       src/util/       SRCUTL        Source for Binary utilities
       webcgi/         CGIDIR        CGI subdirectories; for URL use CGIURL
       webcgi/util/    CGIUTL        CGI utilities
       webdoc/         WEBDOC        Public documents; for URL use WEBURL
       webdoc/images   IMGDIR        Web images; for URL use IMGURL
       webdoc/DTD      DTDDIR        DTD specs; for URL use DTDURL
       webdoc/index.html             Default welcome page

    * = required subdirectories ... all others are optional
	(the only required module in "lib" is "Local.pm")


=head1 INHERITANCE

The B<PTools::Local> class inherits from this B<PTools::Global> abstract 
base class.

=head1 SEE ALSO

See L<PTools::Local>.

In addition, general documention about the Perl Tools Framework is available.

See L<http://www.ccobb.net/ptools/>.

=head1 AUTHOR

Chris Cobb [no dot spam at ccobb dot net]

=head1 COPYRIGHT

Copyright (c) 1997-2007 by Chris Cobb. All rights reserved.
This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
