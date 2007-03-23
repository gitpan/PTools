# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl PTools.t'

#########################

use Test::More tests => 2;

BEGIN { use_ok('PTools::Proc::Daemonize') };                # 01

my $daemon = new PTools::Proc::Daemonize();
ok( defined $daemon, "Instantiation okay" );                # 02

# TODO: more tests...
#########################
