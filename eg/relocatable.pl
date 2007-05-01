#!/opt/perl/bin/perl
#
# File:  relocatable.pl
# Desc:  A complete and completely relocatable 9-line script.
#
use Cwd;
BEGIN {  # Script is relocatable. See http://ccobb.net/ptools/
  my $cwd = $1 if ( $0 =~ m#^(.*/)?.*# );  chdir( "$cwd/.." );
  my($top,$app)=($1,$2) if ( getcwd() =~ m#^(.*)(?=/)/?(.*)#);
  $ENV{'PTOOLS_TOPDIR'} = $top;  $ENV{'PTOOLS_APPDIR'} = $app;
} #-----------------------------------------------------------
use PTools::Local;          # PTools local/global vars/methods

#use MyMain::Module;        # then your script begins here #
#exit( run MyMain::Module() );

#__END__
#use lib "/some/legacy/lib";                     # other libs
 warn PTools::Local->dump('incpaths');           # @INC paths
#warn PTools::Local->dump('inclibs');            # class list
#warn PTools::Local->dump('inclibs, incpaths');  # two in one
#warn PTools::Local->dump('vars');               # local vars

__END__

=item NAME

relocatable.pl - A complete and completely relocatable 9-line script

=head1 SYNOPSIS

 use Cwd;
 BEGIN {  # Script is relocatable. See http://ccobb.net/ptools/
   my $cwd = $1 if ( $0 =~ m#^(.*/)?.*# );  chdir( "$cwd/.." );
   my($top,$app)=($1,$2) if ( getcwd() =~ m#^(.*)(?=/)/?(.*)#);
   $ENV{'PTOOLS_TOPDIR'} = $top;  $ENV{'PTOOLS_APPDIR'} = $app;
 } #-----------------------------------------------------------
 use PTools::Local;          # PTools local/global vars/methods

 use MyMain::Module;         # then your script begins here #
 exit( run MyMain::Module() );


=head1 DESCRIPTION

For B<completely> 'relocatable' scripts, just add the first seven lines,
above, to the very top of a Perl script. Place a copy of PTools::Local in
the directory generated in the 'use lib' line and this module will figure
out the rest. After this, as long as a relative directory structure is
maintained, your Perl scripts and modules can move to other locations
without changing a thing.

If you have other, legacy Perl library path(s) to include, you can add
them either just above or just below the B<use PTools::Local> line.
Above, and it/they will appear between app lib paths and system paths.
Below, and it/they will appear at the very top of your @INC paths.
(If it's confusing at first, try B<print PTools::Local->dump('incpaths')>
and it will soon become obvious what's happening.)

If you have moved to a pure OO environment, the above nine lines
of code is a B<full and complete example> of a script. It just acts
as an outer block to initiate the main module for some application.

Note: Using PTools::Local sets the current working directory to
the I<parent> of where a given script is located. This is a
necessary part of a 'self-locating' Perl script.

=head1 SEE ALSO

See L<PTools::Local> and L<PTools::Global>.

In addition, general documention about the Perl Tools Framework is 
available at the following URL.

See L<http://www.ccobb.net/ptools/>.

=head1 AUTHOR

Chris Cobb, E<lt>nospamplease@ccobb.netE<gt>

=head1 COPYRIGHT

Copyright (c) 1997-2007 by Chris Cobb. All rights reserved.
This module is free software; you can redistribute it and/or 
modify it under the same terms as Perl itself.

=cut
