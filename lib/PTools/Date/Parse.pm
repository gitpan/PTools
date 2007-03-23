# -*- Perl -*-
#
# File:  PTools/Date/Parse.pm
# Desc:  Provides object oriented interface to the "Date::Parse" class
# Auth:  Chris Cobb <nospamplease@ccobb.net>
# Date:  Tue Jul 13 14:22:31 2004
# Stat:  Production
#

package PTools::Date::Parse;
use strict;
use warnings;
no warnings "redefine";

use vars qw( $VERSION @ISA );
$VERSION = '0.02';
@ISA     = qw( );

use Date::Parse;

sub new      { bless [], ref($_[0])||$_[0] }
sub str2time { shift; Date::Parse::str2time(@_) }
sub strptime { shift; Date::Parse::strptime(@_) }
#_________________________
1; # Required by require()

__END__

=head1 NAME

PTools::Date::Parse - A simple OO interface to Date::Parse

=head1 VERSION

This document describes version 0.01, released July, 2004,
and is designed to be compatible with Date::Parse 2.23.

=head1 SYNOPSIS

        use PTools::Date::Parse;

        $parse = new PTools::Date::Parse;
  -or-  $parse = "PTools::Date::Parse";

        $time  = $parse->str2time("Tue, Jul 13, 13:44:59 PDT 2004");

        (@list)= $parse->strptime("Tue, Jul 13, 13:44:59 PDT 2004");

=head1 DESCRIPTION

Provides an object oriented interface to the B<Date::Parse> class.

=head1 SEE ALSO

See L<Date::Parse>.

=head1 AUTHOR

Chris Cobb, E<lt>nospamplease@ccobb.netE<gt>

=head1 COPYRIGHT

Copyright (c) 2004-2007 by Chris Cobb. All rights reserved.
This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut

