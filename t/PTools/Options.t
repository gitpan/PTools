# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl PTools.t'

#########################

use Test::More tests => 7;

BEGIN { use_ok('PTools::Options') };                 # 01

my $opts = new PTools::Options("Usage: test","h|help");
ok( defined $opts, "Instantiation okay" );           # 02
is ( $opts->usage(), "Usage: test" );                # 03
is ( $opts->formatUsage(), "\n Usage: test\n\n" );   # 04
is ( $opts->optArgs()->[0], "h|help" );              # 05

$opts->set("foo", "bar");
is ( $opts->get("foo"), "bar", "Foo is bar (manual accessor)" );  # 06

$opts->bar("foo");
is ( $opts->bar(), "foo", "Bar is foo (auto accessor)" );         # 07

##warn $opts->dump();

# TODO: actually parse @ARGV

#########################
