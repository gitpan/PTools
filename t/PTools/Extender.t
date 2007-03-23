# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl PTools.t'

#########################

use Test::More tests => 6;

BEGIN { use_ok('PTools::Extender') };   # 01

ok( PTools::Extender->can('extend'),   'Extender can extend()'       ); # 02
ok( PTools::Extender->can('extended'), 'Extender can extended()'     ); # 03
ok( PTools::Extender->can('unextend'), 'Extender can unextend()'     ); # 04
ok( PTools::Extender->can('expand'),   'Extender can expand()'       ); # 05
ok( defined $INC{'PTools/Loader.pm'},  'Extender has PTools::Loader' ); # 06

# TODO: create a test class to use/extend; then add tests here.
#########################
