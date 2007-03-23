# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl PTools.t'

#########################

use Test::More tests => 8;

BEGIN { use_ok('PTools::Global') };                           # 01
my(@expected) = ();
is( @PTools::Local::ISA, @expected, "Inheritance okay");      # 02

my $global = new PTools::Global;
ok( defined $global, "Instantiation okay" );                  # 03

$global->set('libdir', "/some/path");
is( $global->get('libdir'), "/some/path", "Global get okay"); # 04

my $expected = "/some/path/new/part";
is( $global->path('libdir', "new/part"), $expected,
                    "Global path okay (w/o '/')");            # 05

is( $global->path('libdir', "/new/part"), $expected,
                    "Global path okay (with '/')");           # 06

$global->reset('libdir');
is( $global->param('libdir'), undef, "Global reset okay");    # 07

#------------

chomp( $expected = `hostname`);
is( $global->getHostname(), $expected, "Global getHostname() ok"),  # 08

## $expected = "";
## is( $global->getDomain(), $expected, "Global getDomain() ok"),   # 00

#------------
# TODO: Fix: Vars not set as expected under 'make test'... 
# Modify the variable generator to include package space as done 
# with $VERSION and @ISA. (?) Why isn't "Global::..." accessable?
## warn $global->dump('vars');
#########################
