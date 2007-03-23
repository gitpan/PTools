#!/opt/perl/bin/perl -w
#
# File:  genpass.pl
# Desc:  Generate a "super encripted block of zeros" (Un*x-style password)
# Date:  Mon Oct 30 11:59:58 2000
# Stat:  Demo
# Usage:
#    genpass.pl foo                     # for example, "qMy7UraSp71Gs"
#    genpass.pl -c qMy7UraSp71Gs foo    # in this case, "Yep, they match"
#
use strict;
use PTools::Global;
use PTools::Passwd;

my($base)  = ( $0 =~ m#^(?:.*/)?(.*)# );
my $Usage  = "\nUsage: $base plaintext";
   $Usage .= "\n       $base -c encryptedtext plaintext\n";

my $text = $ARGV[0] || '';
my($pass,$word) = ();
my($passUtil)   = "PTools::Passwd";

($text eq "-h") and die "$Usage\n";

if ($text eq "-c") {
   $pass = $ARGV[1] || '';
   $text = $ARGV[2] || '';
   ($pass and $text) or $word = $Usage;
   $word ||= ( $passUtil->verify($text,$pass) 
                ? "Yep, they match" 
                : "No match"
	     );
} else {
   $pass = ( $text ? new $passUtil($text) : "" );
   $word = ( $pass ? $pass->toStr()    : $Usage );
}

print "$word\n";

