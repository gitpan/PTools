# -*- Perl -*-
#
# File:  PTools/Passwd.pm
# Desc:  Generate and validate Unix-style passwords
# Auth:  Adapted from "Object Oriented Perl" by Damian Conway, Chap. 4
# Note:  This version allows checking text against pre-existing passwords.
# Stat:  Production
#
# Examples:
#        use PTools::Passwd;
#
#    Encrypt a text string:
#
#        my $passwd = encrypt PTools::Passwd("clearTextPassword");
#        print "Encrypted password: ", $passwd->toStr(), "\n";
#
#    Invoke a comparison as an object method:
#
#        if ( $passwd->verify("clearTextPassword") ) {
#           print "Yep, they match.\n";
#        } else {
#           print "Nope, no match.\n";
#        }
#
#    Invoke a comparison as a class method:
#
#        if ( PTools::Passwd->verify("clearText","encryptedText") ) {
#           print "Yep, they match.\n";
#        } else {
#           print "Nope, no match.\n";
#        }
#
#    Generate a random password:
#
#        $encryptedText = $passwd->random();       # 12 bytes by default
#        $encryptedText = $passwd->random( 64 );   # 64 bytes by request
#
package PTools::Passwd;
 use strict;

our $PACK    = __PACKAGE__;
our $VERSION = '1.03';
#our @ISA    = qw();

my @salt  = ("A".."Z","a".."z","0".."9","/",".");
my @chars = ();

*encrypt = \&new;

sub new
{   my($class,$text) = @_;
    my $salt = $salt[rand @salt].$salt[rand @salt];
    my $self = crypt($text,$salt);
    return bless \$self, ref($class)||$class;
}

sub verify
{   my($self,$text,$pass) = @_;
    if (ref $self) {                 # Object method needs "$text" only
	my $salt = substr($$self,0,2);
	return crypt($text,$salt) eq $$self;
    } else {                         # Class method needs "$text" and "$pass"
	my $salt = substr($pass,0,2);
	return crypt($text,$salt) eq $pass;
    }
}

sub random
{   my($self,$length) = @_;

    # Generate a random "n" character encrypted password

    $length ||= 12;             # 12 characters by default

    if (! @chars) {             # all printable ascii chars
	foreach (32 .. 126) { push @chars, chr($_); }
    }
    my $text;
    foreach (1 .. $length) {
	$text .= $chars[rand @chars];
    }
    my $salt = $salt[rand @salt].$salt[rand @salt];

    return crypt($text,$salt);
}

sub toStr { ${$_[0]} }
#_________________________
1; # Required by require()

__END__

=head1 NAME

PTools::Passwd - Generate and validate Unix-style passwords

=head1 VERSION

This document describes version 1.03, released October, 2004


=head1 SYNOPSIS

 use PTools::Passwd;

 Encrypt a text string:

     $passwd = encrypt PTools::Passwd("clearTextPassword");
     print "Encrypted password: ", $passwd->toStr(), "\n";

 Invoke a comparison as an object method:

     if ( $passwd->verify("clearTextPassword") ) {
        print "Yep, they match.\n";
     } else {
        print "Nope, no match.\n";
     }

 Invoke a comparison as a class method:

     if ( PTools::Passwd->verify("clearText","encryptedText") ) {
        print "Yep, they match.\n";
     } else {
        print "Nope, no match.\n";
     }

 Generate a random password:

     $encryptedText = $passwd->random();       # 12 bytes by default
     $encryptedText = $passwd->random( 64 );   # 64 bytes by request

=head1 DESCRIPTION

A simple little class to generate and validate Unix-style passwords.

=head1 AUTHOR

Chris Cobb [no dot spam at ccobb dot net]

(Adapted from "Object Oriented Perl" by Damian Conway, Chap. 4)


=head1 COPYRIGHT

Copyright (c) 2004-2007 by Chris Cobb. All rights reserved.
This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
