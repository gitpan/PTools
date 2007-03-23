# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl PTools.t'

use Test::More tests => 28;

BEGIN { use_ok('PTools::Debug') };                  # 01

my $Debug = new PTools::Debug();
ok( defined $Debug, "Debug instantiated" );         # 02
is( $Debug->set(), 0, "Debug not set" );            # 03

is( $Debug->at(0, "Message"), 0, "No Message" );    # 04

$Debug->setLevel( 1 );
is( $Debug->set(),      1, "Debug is set" );        # 05
is( $Debug->atLevel(1), 1, "Debug at level 1"  );   # 06
is( $Debug->atLevel(2), 0, "Debug not level 2" );   # 07

#---------------------------------------------------------
# Messages to STDERR, nothing to STDOUT

use PTools::RedirectIO;
my $io = "PTools::RedirectIO";
my($stdout,$stderr);

$io->redirectStdout();
$io->redirectStderr();
is( $Debug->at(0, "Message"), 1, "A Message"  );    # 08
$stdout = $io->resetStdout();
$stderr = $io->resetStderr();
is( $stdout, undef,  "No Message" );                # 09
is( $stderr, "DEBUG: Message\n",  "A Message" );    # 10

$Debug->setIndent( 2 );    # see Test 13:

$io->redirectStdout();
$io->redirectStderr();
is( $Debug->at(1, "Message"), 1, "A Message"  );    # 11
$stdout = $io->resetStdout();
$stderr = $io->resetStderr();
is( $stdout, undef,  "No Message" );                # 12
is( $stderr, "  DEBUG: Message\n",  "A Message" );  # 13

$io->redirectStdout();
$io->redirectStderr();
is( $Debug->at(2, "Message"), 0, "No Message" );    # 14
$stdout = $io->resetStdout();
$stderr = $io->resetStderr();
is( $stdout, undef,  "No Message" );                # 15
is( $stderr, undef,  "No Message" );                # 16

#---------------------------------------------------------
# Messages to STDOUT, nothing to STDERR

$Debug->resetWarn();
$Debug->setIndent( 0 );

$io->redirectStdout();
$io->redirectStderr();
is( $Debug->at(0, "Message"), 1, "A Message"  );    # 17
$stdout = $io->resetStdout();
$stderr = $io->resetStderr();
is( $stdout, "DEBUG: Message\n",  "A Message" );    # 18
is( $stderr, undef,  "No Message" );                # 19

$Debug->setIndent( 2 );   # see Test 21:

$io->redirectStdout();
$io->redirectStderr();
is( $Debug->at(1, "Message"), 1, "A Message"  );    # 20
$stdout = $io->resetStdout();
$stderr = $io->resetStderr();
is( $stdout, "  DEBUG: Message\n",  "A Message" );  # 21
is( $stderr, undef,  "No Message" );                # 22

$io->redirectStdout();
$io->redirectStderr();
is( $Debug->at(2, "Message"), 0, "No Message" );    # 23
$stdout = $io->resetStdout();
$stderr = $io->resetStderr();
is( $stdout, undef,  "No Message" );                # 24
is( $stderr, undef,  "No Message" );                # 25

#---------------------------------------------------------

$Debug->setWarn();
$Debug->setIndent( 0 );
$Debug->setPrefix("TEST: ");

$io->redirectStdout();
$io->redirectStderr();
is( $Debug->at(1, "Message"), 1, "A Message"  );    # 26
$stdout = $io->resetStdout();
$stderr = $io->resetStderr();
is( $stdout, undef,  "No Message" );                # 27
is( $stderr, "TEST: Message\n",  "A Message" );     # 28

#########################
