# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl PTools.t'

#########################

use Test::More tests => 9;

BEGIN { use_ok('PTools::Local') };                           # 01
my(@expected) = ("PTools::Global");
is( @PTools::Local::ISA, @expected, "Inheritance okay");     # 02

my $local = new PTools::Local;
ok( defined $local, "Instantiation okay" );                  # 03

$local->set('libdir', "/some/path");
is( $local->get('libdir'), "/some/path", "Global get okay");      # 04

$local->set('app_libdir', "/other/path");
is( $local->get('app_libdir'), "/other/path", "Local get okay");  # 05

isnt( $local->get('libdir'), $local->get('app_libdir'),
                    "Global is not Local-okay");             # 06

$local->reset('libdir');
is( $local->param('libdir'), undef, "Global reset okay");    # 07

my $expected = "/other/path/new/part";
is( $local->path('app_libdir', "new/part"), $expected,
                    "Local path okay (w/o '/')");            # 08

is( $local->path('app_libdir', "/new/part"), $expected,
                    "Local path okay (with '/')");           # 09

#------------
# TODO: Fix: Vars not set as expected under 'make test'... 
# Modify the variable generator to include package space as done 
# with $VERSION and @ISA. (?) Why isn't "Global::..." accessable?
## warn $local->dump();
## warn $local->dump('incpath');
#########################
