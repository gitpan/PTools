#line 1
package Module::Install::WriteAll;

use strict;
use Module::Install::Base;

use vars qw{$VERSION $ISCORE @ISA};
BEGIN {
	$VERSION = '0.65';
	$ISCORE  = 1;
	@ISA     = qw{Module::Install::Base};
}

sub WriteAll {
    my $self = shift;
    my %args = (
        meta        => 1,
        sign        => 0,
        inline      => 0,
        check_nmake => 1,
        @_
    );

    $self->sign(1)                if $args{sign};
    $self->Meta->write            if $args{meta};
    $self->admin->WriteAll(%args) if $self->is_admin;

    if ( $0 =~ /Build.PL$/i ) {
        $self->Build->write;
    } else {
        $self->check_nmake if $args{check_nmake};
        unless ( $self->makemaker_args->{'PL_FILES'} ) {
        	$self->makemaker_args( PL_FILES => {} );
        }
        if ($args{inline}) {
            $self->Inline->write;
        } else {
        #---------------------------------------------------------------
        # hack by ccobb on Mon Apr 30 06:06:26 2007
        ### $self->Makefile->write;
            $self->Makefile->write ( $args{meta} );
        #---------------------------------------------------------------
        }
    }
}

1;
