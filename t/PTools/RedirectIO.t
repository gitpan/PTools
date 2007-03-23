# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl PTools.t'

#########################
# Not so much here...this class already got a workout
# in the Debug.t unit test. Broken, I know. Need to
# reorder all tests using numeric prefixes...yep.

use Test::More tests => 1;

BEGIN { use_ok('PTools::RedirectIO') };

#########################

