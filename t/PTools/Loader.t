# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl PTools.t'

#########################

use Test::More tests => 6;

BEGIN { use_ok('PTools::Loader' ) };    # 1

my $Loader = 'PTools::Loader';

$Loader->use('PTools::Counter');
ok( defined $INC{ 'PTools/Counter.pm' },    'loaded Counter'  );    # 2

$Loader->use('PTools::Options');
ok( defined $INC{ 'PTools/Options.pm' },    'loaded Options'  );    # 3

$Loader->use('PTools::Debug');
ok( defined $INC{ 'PTools/Debug.pm' },      'loaded Debug'    );    # 4

ok( ! defined $INC{ 'PTools/Verbose.pm' },  '! loaded Verbose');    # 5
ok( ! defined $INC{ 'PTools/Global.pm' },   '! loaded Global' );    # 6

#########################

# TODO:  test abort message, delayed abort
