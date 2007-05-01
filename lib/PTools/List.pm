# -*- Perl -*-
#
# File:  PTools/List.pm
# Desc:  Package up lists of things indexed by a label
# Date:  Mon Jun  1 09:34:52 PDT 1998
# Lang:  Perl
# Stat:  Production
#
# Synopsis:
#        use PTools::List;
#
#        $Notice = new PTools::List;               # start Notices
#        $Notice->add("Error","Err1","Err2");      # add two Errors
#
#        $Warn = new PTools::List("Warning","A warning");
#                                                  # start Warnings
#        $Warn->add("Warning","Another warning");  # add to Warnings
#        $Notice->add($Warn);                      # add to Notices
#
#        print $Notice->dump;                      # view contents
#
#        print $notice->format();                  # format output
#
#        print $notice->summary();                 # format summary
#
package PTools::List;
use strict;
use warnings;

our $PACK    = __PACKAGE__;
our $VERSION = '1.04';
our @ISA     = qw();

use PTools::String;

my $String = "PTools::String";

sub new 
{   my($class,$label,@list) = @_;
    my $self = bless {}, ref($class)||$class;

    $self->add($label,@list) if $label;
    return $self;
}

sub add 
{   my($self,$label,@list) = @_;

    if (ref $label and $label->isa($PACK)) {
	$self->addToSelf($label);
    } else {
	$self->{$label} = [] if ! $self->{$label};
	push @{ $self->{$label} }, @list;
    }
    return;
}

sub addToSelf
{   my($self,$ref) = @_;

    foreach (keys %$ref) {
        next if ! $ref->{$_};
        $self->add($_, @{ $ref->{$_} });
    }
    return;
}

sub reset
{   my($self,$label) = @_;
    return $self->{$label} = undef;
}

*get = \&return;         # "get" is alias for "return" method

sub return               # return list, if any
{   my($self,$label) = @_;
    #
    # This allows storing multiple refs! Just remember to request
    # the return in a "list" context even if only one ref is stored.
    # Otherwise "join" will destroy the ref ... all you'll get is
    # a string that LOOKS like a ref. Now THAT'S hard to debug.
    #
    #  $theRef = {};                # start a reference
    #  $list   = new PTools::List;  # start new list
    #  $list->add('refLabel', $theRef);
    # ($newRef)= $list->return('refLabel');
    #
    return if !defined $self->{$label};
    return @{ $self->{$label} } if wantarray;
    return join("\n", @{ $self->{$label} });
}

sub occurred             # return count or typesOf
{   my($self,$label) = @_;

    if ($label) {
        scalar $self->{$label} or return 0;
        return $#{ $self->{$label} } + 1;
    } else {
	my @labels = ();
        foreach (sort keys %$self) {
	    push(@labels, $_) if scalar $self->{$_};
        }
        return if ! @labels;
        return @labels if wantarray;
        return join(" ",@labels);
    }
    return;
}

sub format
{   my($self,@labels) = @_;
    (@labels) or (@labels) = $self->occurred();

    my $text = "";
    foreach (@labels) {
	next unless $self->occurred( $_ );
	$text and $text .= "\n";
	$text .= "$_:\n";
        foreach my $item (@{ $self->{$_} }) {
	    $text .= "   $item\n";
        }
    }
    ## chomp( $text );
    return $text;
}

sub summary
{   my($self,$title,@labels) = @_;
    (@labels) or (@labels) = $self->occurred();

    my $text = "";
    return $text unless @labels;

    my($len1,$len2,$label) = (0,0,"");
    my($value,$space,@values) = ("","",());

    foreach my $idx ( 0 .. $#labels ) {
	$label = $labels[ $idx ];
	$value = $self->occurred( $label ) ||0;
	$value = $String->addCommasToNumber( $value );
	$len1  = ( length($label) > $len1 ? length($label) : $len1 );
	$len2  = ( length($value) > $len2 ? length($value) : $len2 );
	push( @values, $value );
    }

    if ( $title ) {
	$text .= "$title\n";
	$space = "  " 
    }
    foreach my $idx ( 0 .. $#labels ) {
	$label = $String->justifyRight( $labels[ $idx ], ($len1 ||0) );
	$value = $String->justifyRight( $values[ $idx ], ($len2 ||0) );
	$text .= $space . "$label:  $value\n";
    }
    ## chomp( $text );
    return $text;
}

sub dump
{   my($self) = @_;
    my($text)= "DEBUG: ($PACK:dump) self='$self'\n";
    my($pack,$file,$line)=caller();
    $text   .= "CALLER $pack at line $line ($file)\n";
    foreach (sort keys %$self) {
        $text .= "$_\n";
        no strict "refs";  # allow string as ARRAY ref here
        foreach my $item (@{ $self->{$_} }) {
	    $text .= "   $item\n";
        }
    }
    $text .= "____________\n";
    return($text);
}
#_________________________
1; # Required by require()

__END__

=head1 NAME

PTools::List - Create lists of things indexed by a label

=head1 VERSION

This document describes version 1.04, released October, 2004

=head1 SYNOPSIS

 use PTools::List;

 $notice = new PTools::List;               # start Notices
 $notice->add("Error","Err1","Err2");      # add two Errors

 $warn = new PTools::List("Warning","A warning");

 $warn->add("Warning","Another warning");  # add to Warnings
 $notice->add($warn);                      # add to Notices

 print $notice->dump;                      # view contents

 print $notice->format();                  # format output

 print $notice->summary();                 # format summary


=head1 DESCRIPTION

=head2 Constructor

=over 4

=item new ( Label [, Value [,Value...] ] )

The B<new> method is called to create a new object that is
used to collect various lists of things. Each list will have
a unique label name and zero or more items in the list.
Initial values are optional and may be added at any time.

=over 4

=item Label

The required B<Label> is used to identify a unique list.

=item Value

An optional list of B<Value>s can be added during object creation.
Perl references can be included in any list, but make sure to read
the warning in the L<return> method.

=back

=back


=head2 Methods

=over 4

=item add ( Label [, Value [, Value... ] ] )

This method is used to add items to an existing list.

=over 4

=item Label

An identifier for a list. If an existing B<Label> name is used here
any B<Value>s will be added to that list. If the name does not yet
exist, a new list is created.

=item Value

The B<Value>s are added to the named list.

=back

=back


=over 4

=item reset ( Label )

Reset the list named by B<Label> to an empty value.


=item get ( Label )

=item return  ( Label )

The B<get> and B<return> method will return any value(s) contained
in the list named by B<Label>. 

B<Warning>: Perl references may be stored in any list. However,
if you do so, make B<sure> to invoke this method in B<list>
context, or you will be B<very> disappointed by the result.
(In scalar context, you will get a string that B<looks> like a 
reference, and it will be extremely frustrating spending time 
debugging that!)

For example:

  $hashRef = { foo => "bar", abc => "xyzzy" };

  $list = new PTools::List( 'test', $hashRef );

  (@items) = $list->return();       # MUST set "(@items) = " here.


=item occurred ( Label )

Check to see if any items are in the list indicated by B<Label>.


=item format ( [ Label [, Label...] ] )

Returns a formatted string of the current contents. An optional
list of one or more B<Label>s can be added to limit the output
to only contain one or some B<Label> identifiers.

=item summary ( [ Title ] [, Label [, Label...] ] )

Returns a formatted summary of the current contents. An optional
list of one or more B<Label>s can be added to limit the output
to only contain one or some B<Label> identifiers. An optional
B<Title> can be added to the output.

=item dump ()

During testing or debugging this method will return a string
showing the raw contents of the current object. Output includes
where the method was called from, and the class and object
where the method resides.

=back

=head1 WARNINGS

Perl references may be stored in any list. However,
if you do so, make B<sure> to invoke this method in B<list>
context, or you will be B<very> disappointed by the result.

In scalar context, you will get a string that B<looks> like a 
reference, and it will be extremely frustrating spending time 
debugging that!

=head1 AUTHOR

Chris Cobb [no dot spam at ccobb dot net]

=head1 COPYRIGHT

Copyright (c) 1998-2007 by Chris Cobb. All rights reserved.
This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
