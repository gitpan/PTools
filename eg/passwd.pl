#!/opt/perl/bin/perl -w
#
# File:  passwd.pl
# Desc:  Demo of using the SDF::File::Passwd module
# Date:  Wed Jul 10 16:18:01 2002
# Stat:  Demo
#
# Usage:
#        passwd.pl <uname>
#
use strict;
use warnings;


# use SDF::File::Passwd qw( NIS );         # obtain data via NIS+
  use SDF::File::Passwd;                   # obtain data from /etc/passwd


my($base) = ( $0 =~ m#^(?:.*/)?(.*)# );    # name of this script
my $uname = $ARGV[0] || die "\n Usage: $base <uname> \n\n";
my $pwObj = new SDF::File::Passwd;

 print "Lookup user info using either /etc/passwd or NIS\n";
#_________________________________________
# Part 1: Attempt to fetch a passwd entry

 my(@pwEntry) = $pwObj->getPwent( $uname );
 my $mode     = $pwObj->getMode();

 die "\n no passwd entry found for user '$uname' using $mode\n\n"
    unless $#pwEntry > 0;

 print "\n";
 print " passwd entry found using $mode\n";
 print "        uname: $pwEntry[0]\n";
 print "       passwd: $pwEntry[1]\n";
 print "          uid: $pwEntry[2]\n";
 print "          gid: $pwEntry[3]\n";
 print "         gcos: $pwEntry[4]\n";
 print "          dir: $pwEntry[5]\n";
 print "        shell: $pwEntry[6]\n";
 print "\n";

#_________________________________________
# Part 2: Parse the gcos field entry

 my($gcosRef, @gcos);

 (@gcos) = $pwObj->getGcos( $uname );

 $gcosRef = $pwObj->parseGcos( @gcos );

 exit(0) unless (keys %$gcosRef);   # ----- Exit early if no parsed result

 print "  gcos fields\n";

 foreach my $key ( sort keys %$gcosRef ) {
    printf(" %12s: %-30s\n",  $key, $gcosRef->{$key} );
 }
 print "\n";
