#!/opt/perl/bin/perl -w
#
# File:  runProc.pl
# Desc:  Demo of using the PTools::Proc::Run module
# Date:  Sun Mar 18 10:56:38 2007
# Stat:  Demo
#
# Usage:
#        runProc.pl <command>
#
use strict;
use warnings;

use PTools::Proc::Run;

my $cmd = "PTools::Proc::Run";

#my($stat,$result) = run $cmd echo => "foo";
#my($stat,$result) = run $cmd xyz => "foo";
 my($stat,$result) = run $cmd "true";
#my($stat,$result) = run $cmd "false";

warn "Apre run: stat='$stat' result='$result'";
