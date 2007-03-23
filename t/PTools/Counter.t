# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl PTools.t'

#########################
use Test::More tests => 30;

BEGIN { use_ok('PTools::Counter') };                   # 01

my $ctr = new PTools::Counter;
ok( defined $ctr,                 'is defined' );      # 02

$ctr->init('error', "Errors: ");
ok( defined $ctr->value('error'), 'is defined' );      # 03
ok( ! $ctr->value('error'),       'is zero'    );      # 04

$ctr->incr('error');
ok( $ctr->value('error') == 1,    'is one'     );      # 05

$ctr->decr('error');
ok( defined $ctr->value('error'), 'is defined' );      # 06
ok( ! $ctr->value('error'),       'is zero'    );      # 07

$ctr->incr('error', 5);
ok( $ctr->value('error') == 5,    'is five'    );      # 08

$ctr->reset('error');
ok( defined $ctr->value('error'), 'is defined' );      # 09
ok( ! $ctr->value('error'),       'is zero'    );      # 10

my $PACK = "PTools::Counter";
$ctr->init();
my($stat,$err) = $ctr->status();         # 11.
ok( ($stat == -1 && $err eq "Required param 'counter' missing in '$PACK'"),
                                  'has error'  );      # 11

$ctr->init('error');
ok( defined $ctr->value('error'), 'is defined' );      # 12
ok( ! $ctr->value('error'),       'is zero'    );      # 13

$ctr->del('error');
ok( ! defined $ctr->{error},      'not defined');      # 14

$ctr->init('warn', "Warning", "s:", ":");
$ctr->incr('warn');
ok( $ctr->result('warn') eq "Warning: 1", 'good result'  );  # 15

$ctr->incr('warn');
my $tmp = $ctr->result('warn');
ok( $ctr->result('warn') eq "Warnings: 2", 'good result' );  # 16

#-----------------------------------------------------------------------
$ctr = new PTools::Counter;

$ctr->init('warn', "Warnings: ");
$ctr->incr('warn');
ok( $ctr->format() eq "Warnings: 1\n",     'good format' );  # 17

$ctr->incr('warn');
ok( $ctr->format() eq "Warnings: 2\n",     'good format' );  # 18

$ctr->incr('errs');     # no 'init' yet, should be ignored!
ok( $ctr->format() eq "Warnings: 2\n",     'good format' );  # 19

$ctr->init('errs', "  Errors: ");
ok( $ctr->format() eq "Warnings: 2\n  Errors: 0\n",
                                            'good format' );   # 20
ok( $ctr->format("","","nonZeroOnly") eq "Warnings: 2\n",
                                            'good format' );   # 21
ok( $ctr->format("Header","","nonZeroOnly") eq "Header\nWarnings: 2\n",
                                            'good format' );   # 22
ok( $ctr->format("","Footer","nonZeroOnly") eq "Warnings: 2\nFooter",
                                            'good format' );   # 23

$ctr->incr('errs');
ok( $ctr->format() eq "Warnings: 2\n  Errors: 1\n",
                                            'good format' );   # 24
ok( $ctr->format("","","nonZO") eq "Warnings: 2\n  Errors: 1\n",
                                            'good format' );   # 25

$ctr->head("Header");
ok( $ctr->format() eq "Header\nWarnings: 2\n  Errors: 1\n",
                                            'good format' );   # 26

$ctr->foot("Footer");
ok( $ctr->format() eq "Header\nWarnings: 2\n  Errors: 1\nFooter",
                                            'good format' );   # 27

#-----------------------------------------------------------------------
$ctr = new PTools::Counter;

my $time = '1174285168';       # 19-Mar-2007 00:19:28 (CST)
$ENV{TZ} = "CST7CDT";

TODO: {
    local $TODO = "Can't set TZ in test script?!";

$ctr->start( "Start Time: ", $time );
$ctr->end( "  End Time: ", $time + 100 );
ok( $ctr->format() =~ m#^Start Time: Mon Mar 19 00:19:28 CST 2007\n  End Time: Mon Mar 19 00:21:08 CST 2007\n$#,           'time format' );   # 28

#----------------------------------------------
# A TZ reset works in a "normal" perl script, using this
# exact same example. And it works to 'export TZ=blah' 
# in a shell. So why doesn't setting TZ work here??!!
#
# $ENV{TZ} = "CST7CDT";
#warn "--------------------\n";
#warn( $ctr->format() );
#warn "--------------------\n";
# $ENV{TZ} = "PST8PDT";
#warn( $ctr->format() );
#warn "--------------------\n";
#----------------------------------------------

$ctr->cumulative( "Accum Time: ", 1050 );
ok( $ctr->format() =~ m#^Start Time: Mon Mar 19 00:19:28 CST 2007\n  End Time: Mon Mar 19 00:21:08 CST 2007\nAccum Time: 17 minutes, 30 seconds\n$#,  
                                           'time format' );   # 29

$ctr->tmFormat( "%c" );
ok( $ctr->format() =~ m#^Start Time: 03/19/07 00:19:28\n  End Time: 03/19/07 00:21:08\nAccum Time: 17 minutes, 30 seconds\n$#,  
                                           'time format' );   # 30

} # End of TODO block
#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

