# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl PTools.t'

#########################

use Test::More tests => 7;

BEGIN { use_ok('PTools', qw(Counter Loader Options Debug),  ) };    # 1

ok( defined $INC{ 'PTools/Counter.pm' },    'loaded Counter'  );    # 2
ok( defined $INC{ 'PTools/Loader.pm' },     'loaded Loader'   );    # 3
ok( defined $INC{ 'PTools/Options.pm' },    'loaded Options'  );    # 4
ok( defined $INC{ 'PTools/Debug.pm' },      'loaded Debug'    );    # 5
ok( ! defined $INC{ 'PTools/Verbose.pm' },  '! loaded Verbose');    # 6
ok( ! defined $INC{ 'PTools/Global.pm' },   '! loaded Global' );    # 7

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

