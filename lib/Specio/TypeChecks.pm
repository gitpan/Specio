package Specio::TypeChecks;
$Specio::TypeChecks::VERSION = '0.11';
use strict;
use warnings;

use Exporter qw( import );
use Module::Runtime qw( is_module_name );
use Scalar::Util qw( blessed );

our @EXPORT_OK = qw(
    does_role
    is_ArrayRef
    is_ClassName
    is_CodeRef
    is_HashRef
    is_Int
    is_Str
    isa_class
);

sub is_ArrayRef {
    return ref $_[0] eq 'ARRAY';
}

sub is_CodeRef {
    return ref $_[0] eq 'CODE';
}

sub is_HashRef {
    return ref $_[0] eq 'HASH';
}

sub is_Str {
    defined( $_[0] ) && !ref( $_[0] ) && ref( \$_[0] ) eq 'SCALAR'
        || ref( \( my $val = $_[0] ) eq 'SCALAR' );
}

sub is_Int {
    ( defined( $_[0] ) && !ref( $_[0] ) && ref( \$_[0] ) eq 'SCALAR'
            || ref( \( my $val = $_[0] ) eq 'SCALAR' ) )
        && $_[0] =~ /^[0-9]+$/;
}

sub is_ClassName {
    is_module_name( $_[0] );
}

sub isa_class {
    blessed( $_[0] ) && $_[0]->isa( $_[1] );
}

sub does_role {
    blessed( $_[0] ) && $_[0]->can('does') && $_[0]->does( $_[1] );
}

1;

# ABSTRACT: Type checks used internally for Specio classes (it's not self-bootstrapping (yet?))

__END__

=pod

=encoding UTF-8

=head1 NAME

Specio::TypeChecks - Type checks used internally for Specio classes (it's not self-bootstrapping (yet?))

=head1 VERSION

version 0.11

=head1 DESCRIPTION

There's nothing public here.

=for Pod::Coverage .*

=head1 AUTHOR

Dave Rolsky <autarch@urth.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2014 by Dave Rolsky.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=cut
