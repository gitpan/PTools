# -*- Perl -*-
#
# File:  PTools/Extender.pm
# Desc:  Abstract class to facilitate "extendable" methods in a module
# Date:  Wed May 09 10:59:60 2001
# Stat:  Prototype  (never made it to production)
#
# Abstract:
#        This "utility" module provides a simple mechanism for developers 
#        of Perl modules to provide "extendable" methods in their classes.
#        Using this module as a base class for a module, and using the
#        methods as shown below, allows the USER of the derived class to
#        specify which module that THEY choose to use, and even allows
#        the user to create their own modules and "hook" them in.
#
#        Clear as mud? Some examples will help bring this into focus.
#
#        Say, for example, you are building a module that reads data files
#        into memory (let's call the module "NewFileModule.pm"). As part 
#        of the design, you decide that it would be nice to provide a few
#        methods that help manage the data while it resides in memory.
#        For this example, methods will include "sort", "lock" and "unlock."
#        
#        Further, since there are run-time issues that may make your default
#        solution less than optimal, you decide that anyone who uses your
#        module can choose which module will actually accomplish these tasks.
#
#        For the examples below these will be termed "extendable" methods,
#        and will include the following variations.
#        .  Sort Modules:  Sort::Bubble,   Sort::Shell, Sort::Quick
#        .  Lock Modules:  Lock::Advisory, Lock::Hard,  Lock::Time
#
# Synopsis:
#
#  First, include "PTools::Extender" as a "base classe" for YOUR module.
#
#        package NewFileModule;
#
#        use vars qw( $VERSION @ISA );
#        $VERSION = '0.01';
#        @ISA     = qw( PTools::Extender );
#       
#        use PTools::Extender;
#        
#  Then, to create an "extendable" method, code the subroutine as follows.
#  Note that, using this syntax, the actual Lock module is not pulled into
#  the script until the first time the "lock" method is called. This may 
#  not be what you want. To load the Lock module when the script starts,
#  simply use the "extend" method, as shown below, and specify the default
#  Lock module.
#
#        sub lock {
#            my($self,@params) = @_;
#
#            my($ref,$stat,$err) = (undef,0,"");
#            #
#            # If not already extended, use default extension class
#            #
#            $ref = $self->extended("lock");
#            $ref or ($ref,$stat,$err) =
#                      $self->extend( ["lock","unlock"], "Lock::Advisory" );
#            #
#            # Invoke the extended method
#            #
#            $stat or ($stat,$err) = $self->expand('lock',@params);
#        
#            $self->setErr( $stat,$err );
#            return($stat,$err) if wantarray;
#            return $stat;
#        }
#
#        sub unlock {
#           my($self,@params) = @_;
#           #
#           # Invoke the extended method. This implies
#           # that 'lock' must have been called (or
#           # 'unlock' extended) first.
#           #
#           my($stat,$err) = $self->expand('unlock',@params);
#
#           $self->setErr( $stat,$err );
#           return($stat,$err) if wantarray;
#           return $stat;
#        }
#
#  This way, when a Perl programmer uses the NewFileModule, s/he decides
#  which lock module will actually be used. By default it's your choice:
#
#        use NewFileModule;
#
#        $fileObj = new NewFileModule( $fileName );   # open file (e.g.)
#
#        $stat = $fileObj->lock;                      # use default lock
#
#        $stat = $fileObj->unlock;                    # use default unlock
#
#
#  Or they can choose another module at any time from their script. The
#  syntax for calling the actual "extended" method(s) need not change
#  (unless, of course, the "extended" module expects different params!)
#
#        use NewFileModule;
#
#        $fileObj = new NewFileModule( $fileName );   # open file (e.g.)
#
#        $fileObj->extend( ["lock","unlock], "Lock::Hard" );
#
#        $stat = $fileObj->lock;                      # "Hard" lock instead
#
#        $stat = $fileObj->unlock;                    # "Hard" unlock instead
#
#
#  It is also possible to pass both "import" and "instantiation" parameters
#  to the "extended" object as follows. Note that the brackets ("[]") below
#  are literal and not to denote optional params. They are used to create 
#  array references that are passed to the object under creation.
#
#        $fileObj->extend( "method", "className",
#			 [ "paramRef1" ], [ "qw( paramRef2 )" ] );
#
#  Where the "paramRef1" (etc.) is passed to the "new" method, 
#    and the "paramRef2" (etc.) is passed to the "use" function
#
#
#  This assumes that the lock modules are well behaved and work in this
#  environment. Note well that the "expand" method prepends "$self" to
#  the argument list. Without this, the utility module "lock", "sort" or
#  whatever, would not have access to the data to lock/sort. However, the
#  extended module must be designed for this.
#

package PTools::Extender;
use strict;
use warnings;

our $PACK    = __PACKAGE__;
our $VERSION = '0.04';
our @ISA     = qw( );

use PTools::Loader qw( generror );   # demand-load Perl modules; abort on error

my $Loader = "PTools::Loader";

### new    { bless {}, ref($_[0])||$_[0]  }   # $self is a simple hash ref.
### setErr { return( $_[0]->{STATUS}=$_[1]||0, $_[0]->{ERROR}=$_[2]||"" ) }
### status { return( $_[0]->{STATUS}||0, $_[0]->{ERROR}||"" )             }

#_____________________________________________________________
# Allow user-defined replacement for some methods.
# however, only "extendible" methods are extended.
#
sub extend {
   my($self,$methods,$class,$paramRef,$useRef) = @_;

   my($ref,$stat,$err) = (undef,0,"");
   my(@params) = $paramRef ? @{$paramRef} : ();
   my(@useArg) = $useRef   ? @{$useRef} : ();

   if (0) {
	print "DEBUG: methods='$methods'\n";
	print "DEBUG:   class='$class'\n";
	print "DEBUG:  params='@{$paramRef}'\n"   if $paramRef;
	print "DEBUG: use arg='@{$useRef}'\n"     if $useRef;
   }

   $Loader->use( $class, @useArg );    # use the requested class or die trying

   ($ref,$stat,$err) = $class->new( @params );       # Instantiate extension

   if (! $ref) { 
	# do nothing if instantiation failed
   } elsif (ref $methods) {
	map { $self->{"ext_$_"} = $ref } @$methods;  # eg, ["lock","unlock"]
   } else {
	$self->{"ext_$methods"} = $ref;              # eg, "sort"
   }

   $self->setErr($stat,$err);
   return $ref unless wantarray;
   return($ref,$stat,$err);
}

#______________________________________________
# The "extended" method will return a reference to a previously 
# extended method. Clear as mud? See usage in examples above and 
# in the "expand" method, below.
#
sub extended { $_[0]->{"ext_$_[1]"} }

#______________________________________________
# Remove reference(s) to previously extended method(s).
#
sub unextend { 
   my($self,$methods) = @_;

   if (ref $methods) {
      map { $self->{"ext_$_"} = undef } @$methods; # eg, ["lock","unlock"]
   } else {
      $self->{"ext_$methods"} = undef;             # eg, "sort"
   }
   return;
}
#______________________________________________
# The expand method is used by extendible methods to invoke the 
# "extended" object. This method should be considered "protected" 
# or private to subclasses of this package.
#
# NOTE that the current object ($self) is prepended to the @params 
# list during callback. This what allows the "utility" module to
# gain access to data in the current object.
#
sub expand {
   my($self,$method,@params) = @_;

   my($ref,$stat,$err);

   $ref = $self->extended($method);
   #_______
   # Verify we actually can invoke $method 
   #
   my($pack,$file,$line)=caller();
   my $module = $pack .".pm";
      $module =~ s#::#/#g;

   ref $ref or ($stat,$err) = 
      (-1,"No object found for '$method' in '$module' at line $line ($PACK)");

   $stat or $ref->can($method) or ($stat,$err) = 
      (-1,"No '$method' method available in '$module' at line $line ($PACK)");
   #_______
   # Invoke the object associated with this method
   # (note that $self is prepended to @params list).
   #
   $stat or ($stat,$err) = $ref->$method($self,@params);

   return $stat unless wantarray;
   return($stat,$err);
}
#_________________________
1; # required by require()

__END__

=head1 NAME

PTools::Extender - Abstract class facilitates "extendable" methods in modules

=head1 VERSION

This document describes version 0.03, released Nov 12, 2002.


=head1 DEPENDENCIES

This class depends upon the B<Loader> class to dynamically B<use> the
"extended" Perl module at run time.


=head1 SYNOPSIS

First, include B<PTools::Extender> as a "base classe" for YOUR module.

  package MyModule;

  use vars qw( $VERSION @ISA );
  $VERSION = '0.01';
  @ISA     = qw( PTools::Extender );

  use PTools::Extender;

Then, to create an "extendable" method, code the subroutine using the 
following methods contained in this class. See Example section, below.

  $ref = $self->extended( 'myMethod' );

  if ( $self->extended( 'myMethod' ) { . . . }

  $stat or ($stat,$err) = $self->expand( 'myMethod', @params);

  $self->unextend( 'myMethod' );


=head1 DESCRIPTION

This "utility" module provides a simple mechanism for developers 
of Perl modules to provide "extendable" methods in their classes.
Using this module as a base class for a module, and using the
methods as shown below, allows the USER of the derived class to
specify which module that THEY choose to use, and even allows
the user to create their own modules and "hook" them in.

Clear as mud? Some examples will help bring this into focus.

Say, for example, you are building a module that reads data files
into memory (let's call the module "NewFileModule.pm"). As part 
of the design, you decide that it would be nice to provide a few
methods that help manage the data while it resides in memory.
For this example, methods will include "sort", "lock" and "unlock."

Further, since there are run-time issues that may make your default
solution less than optimal, you decide that anyone who uses your
module can choose which module will actually accomplish these tasks.

For the examples below these will be termed "extendable" methods,
and will include the following variations.

  Sort Modules:   Sort::Bubble,   Sort::Shell, Sort::Quick
  Lock Modules:   Lock::Advisory, Lock::Hard,  Lock::Time


=head2 Constructor

None needed.

=head2 Methods

=over 4

=item extend ( Methods, Class [, ParamRef ] [, UseRef ] )

The mechanism defined within a subclass that implements an
B<extended> method.

=over 4

=item Methods

The name or names of the methods that will be invoked as
via the method extension mechanism.

=item Class

The name of the module or B<Class> that contains the
B<extended> method definitions.

=item ParamRef

Optional parameters passed to the constructor method of the B<Class>.

=item UseRef

Optional parameters passed to the B<use> statement of the B<Class>.

=back

Example:

 $userObj->extend( "method", "className",
                 [ "paramRef1" ], [ "qw( paramRef2 )" ] );

This method will be invoked in some user module or script that
B<uses> the class containing the "extendable" methods.

The B<$userObj> object will be an instantiation of the module
that is created in the examples under discussion here.


=item unextend ( Method )

If the specified B<Method> is currently B<extended>, this
will B<unextend> that method.

 $userObj->unextend( $method );

This method will be invoked in some user module or script that
B<uses> the class containing the "extendable" methods.


=item expand ( Method [, Params ] )

The mechanism used inside an "extendable" method definition that invokes 
a previously B<extended> method. B<Method> is the name of the B<extended>
method and B<Params>, if any, are simply forwarded on to the actual method 
that performs the operation. 

Module designers must note that the current B<$self> object
reference is prepended to the B<Params> list. This is how
the "extended" object gains access to the current object.

 ($stat,$err) = $self->expand( $method, @params);


=item extended ( Method )

Test to see if the specified B<Method> is currently B<extended>.

 if ($self->extended( $method ) { . . . }

This method should be available to both the designer of the
module under discussion here and the consumer of the module.

=back


=head1 EXAMPLE

First, include "PTools::Extender" as a "base classe" for YOUR module.

    package NewFileModule;

    use vars qw( $VERSION @ISA );
    $VERSION = '0.01';
    @ISA     = qw( PTools::Extender );

    use PTools::Extender;

Then, to create an "extendable" method, code the subroutine as follows.
Note that, using this syntax, the actual Lock module is not pulled into
the script until the first time the "lock" method is called. This may 
not be what you want. To load the Lock module when the script starts,
simply use the "extend" method, as shown below, and specify the default
Lock module.

    sub lock {
        my($self,@params) = @_;

        my($ref,$stat,$err) = (undef,0,"");
        #
        # If not already extended, use default extension class
        #
        $ref = $self->extended("lock");
        $ref or ($ref,$stat,$err) =
                  $self->extend( ["lock","unlock"], "Lock::Advisory" );
        #
        # Invoke the extended method
        #
        $stat or ($stat,$err) = $self->expand('lock',@params);
    
        $self->setErr( $stat,$err );
        return($stat,$err) if wantarray;
        return $stat;
    }

    sub unlock {
       my($self,@params) = @_;
       #
       # Invoke the extended method. This implies
       # that 'lock' must have been called (or
       # 'unlock' extended) first.
       #
       my($stat,$err) = $self->expand('unlock',@params);

       $self->setErr( $stat,$err );
       return($stat,$err) if wantarray;
       return $stat;
    }

This way, when a Perl programmer uses the NewFileModule, s/he decides
which lock module will actually be used. By default it's your choice:

    use NewFileModule;

    $fileObj = new NewFileModule( $fileName );   # open file (e.g.)

    $stat = $fileObj->lock;                      # use default lock

    $stat = $fileObj->unlock;                    # use default unlock

Or they can choose another module at any time from their script. The
syntax for calling the actual "extended" method(s) need not change
(unless, of course, the "extended" module expects different params!)

    use NewFileModule;

    $fileObj = new NewFileModule( $fileName );   # open file (e.g.)

    $fileObj->extend( ["lock","unlock], "Lock::Hard" );

    $stat = $fileObj->lock;                      # "Hard" lock instead

    $stat = $fileObj->unlock;                    # "Hard" unlock instead

It is also possible to pass both "import" and "instantiation" parameters
to the "extended" object as follows. Note that the brackets ("[]") below
are literal and not to denote optional params. They are used to create 
array references that are passed to the object under creation.

    $fileObj->extend( "method", "className",
                    [ "paramRef1" ], [ "qw( paramRef2 )" ] );

   Where the "paramRef1" (etc.) is passed to the "new" method, 
     and the "paramRef2" (etc.) is passed to the "use" function

This assumes that the lock modules are well behaved and work in this
environment. Note well that the "expand" method prepends "$self" to
the argument list. Without this, the utility module "lock", "sort" or
whatever, would not have access to the data to lock/sort. However, the
extended module must be designed for this.


=head1 SEE ALSO

See L<SDF::File> and L<SDF::Lock::Advisory> for a complete example of
implementing "extendable" methods via "utility" classes.

Also see L<SDF::SDF>, L<SDF::Sort::Bubble>, L<SDF::Sort::Bubble> and
L<SDF::Sort::Bubble> for additional examples.

=head1 INHERITANCE

A module designer's subclass will inherit from this base class.

=head1 AUTHOR

Chris Cobb, E<lt>nospamplease@ccobb.netE<gt>

=head1 COPYRIGHT

Copyright (c) 2004-2007 by Chris Cobb. All rights reserved.
This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
