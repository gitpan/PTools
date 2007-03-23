# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl PTools.t'

#########################

use Test::More tests => 2;

BEGIN { use_ok('PTools::Proc::Run') };          # 01

my $daemon = new PTools::Proc::Run();
ok( defined $daemon, "Instantiation okay" );    # 02

# TODO: more tests...
#########################
