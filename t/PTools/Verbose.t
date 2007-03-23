# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl PTools.t'

#########################
# Not much to do here... most test completed in Debug.t

use Test::More tests => 8;

BEGIN { use_ok('PTools::Verbose') };                  # 01

my $Ver = new PTools::Verbose;
ok( defined $Ver, "Instantiation okay" );             # 02

#---------------------------------------------------------
# Messages to STDOUT, nothing to STDERR

use PTools::RedirectIO;
my $io = "PTools::RedirectIO";
my($stdout,$stderr);

$io->redirectStdout();
$io->redirectStderr();
is( $Ver->at(0, "Some Message"), 0, "A Message"  );   # 03
$stdout = $io->resetStdout();
$stderr = $io->resetStderr();
is( $stdout, undef,  "Nothing on stdout" );           # 04
is( $stderr, undef,  "Nothing on stderr" );           # 05

$Ver->setLevel( 1 );

$io->redirectStdout();
$io->redirectStderr();
is( $Ver->at(0, "Some Message"), 1, "A Message"  );   # 06
$stdout = $io->resetStdout();
$stderr = $io->resetStderr();
is( $stdout, "Some Message\n",  "A Message" );        # 07
is( $stderr, undef,  "Nothing on stderr" );           # 08

#########################
