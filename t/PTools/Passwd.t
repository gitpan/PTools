# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl PTools.t'

#########################

use Test::More tests => 4;

BEGIN { use_ok('PTools::Passwd') };                    # 01

# Object methods
#----------------
my $passwd    = new PTools::Passwd("foo");
my $encrypted = $passwd->toStr();
ok( defined $passwd, "Instantiation okay" );           # 02

is( $passwd->verify("foo"), 1, "Do passwds match?");   # 03

# Class methods
#---------------
$passwd = "PTools::Passwd";
is ( $passwd->verify("foo", $encrypted), 1, "Do passwds match?");  # 04

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

