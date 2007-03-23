#!/opt/perl/bin/perl
#
# File:  redirectIO.pl
# Desc:  Demo of using the PTools::RedirectIO class
#
use 5.006;
use strict;
use warnings;
use PTools::RedirectIO;

my $io = "PTools::RedirectIO";

print "About to redirect stdout...\n";
$io->redirectStdout();
print "foo\n";
print "bar\n";

my $stdout = $io->resetStdout();
print "stdout is now 'unredirected'\n";

#-------------------------------------
print "About to redirect stderr...\n";
$io->redirectStderr();
warn "foo\n";
print STDERR "bar\n";

my $stderr = $io->resetStderr();
print "stderr is now 'unredirected'\n";

#-------------------------------------
print "---------\n";
print "deferred stdout='$stdout'\n";
print "---------\n";
print "deferred stderr='$stderr'\n";
print "---------\n";
