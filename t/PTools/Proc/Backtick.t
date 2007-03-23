# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl PTools.t'

#########################

use Test::More tests => 1;

BEGIN { use_ok('PTools::Proc::Backtick') };            # 01

#chomp( my $echo = `which echo` );
#if (defined $echo) {
#   ok( defined $echo, "Can we find an echo command?");    # 02
#   my $cmdObj = run PTools::Proc::Backtick( $echo, "echo this" );
#
#   my($stat,$err) = $cmdObj->status();
#   ok( $stat == 0, "Can we run an echo command?");        # 03
#}
#########################
