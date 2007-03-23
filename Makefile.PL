# -*- Perl -*-
#
# File:  Makefile.PL
# Desc:  Make the makefile for the PTools distribution
# Date:  Sat Mar 17 14:01:49 2007
#
use inc::Module::Install;

name		'PTools';
author		'Chris Cobb <nospamplease@ccobb.net>';
license 	'perl';
all_from	'lib/PTools.pm';
tests		't/*.t t/*/*.t t/*/*/*.t';

# When building this distribution
no_index	directory 	=> 'eg';
build_requires	Test::More	=> 0;

# Standard modules needed
requires	Carp		=> 0;
requires	Exporter        => 0;
requires	Fcntl		=> 0;
requires	POSIX		=> 0;
requires	strict		=> 0;
requires	warnings	=> 0;

# Additional modules needed
requires 	Date::Format	=> 2.22;
requires 	Date::Parse	=> 2.23;
requires 	Getopt::Long	=> 2.17;

WriteAll();
