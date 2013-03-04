package Specio::Role::Inlinable;
{
  $Specio::Role::Inlinable::VERSION = '0.07';
}

use strict;
use warnings;
use namespace::autoclean;

use Eval::Closure qw( eval_closure );

use Moose::Role;

requires '_build_description';

has _inline_generator => (
    is        => 'ro',
    isa       => 'CodeRef',
    predicate => '_has_inline_generator',
    init_arg  => 'inline_generator',
);

has _inline_environment => (
    is       => 'ro',
    isa      => 'HashRef[Any]',
    lazy     => 1,
    init_arg => 'inline_environment',
    builder  => '_build_inline_environment',
);

has _generated_inline_sub => (
    is       => 'ro',
    isa      => 'CodeRef',
    init_arg => undef,
    lazy     => 1,
    builder  => '_build_generated_inline_sub',
);

has declared_at => (
    is       => 'ro',
    isa      => 'Specio::DeclaredAt',
    required => 1,
);

has _description => (
    is       => 'ro',
    isa      => 'Str',
    init_arg => undef,
    lazy     => 1,
    builder  => '_build_description',
);

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;

    my $p = $class->$orig(@_);

    $p->{inline_generator} = delete $p->{inline} if exists $p->{inline};

    return $p;
};

sub can_be_inlined {
    my $self = shift;

    return $self->_has_inline_generator();
}

sub _build_generated_inline_sub {
    my $self = shift;

    my $source
        = 'sub { ' . $self->_inline_generator()->( $self, '$_[0]' ) . '}';

    return eval_closure(
        source      => $source,
        environment => $self->_inline_environment(),
        description => 'inlined sub for ' . $self->_description(),
    );
}

sub _build_inline_environment {
    return {};
}

1;

# ABSTRACT: A role for things which can be inlined (type constraints and coercions)

__END__

=pod

=head1 NAME

Specio::Role::Inlinable - A role for things which can be inlined (type constraints and coercions)

=head1 VERSION

version 0.07

=head1 DESCRIPTION

This role implements a common API for inlinable things, type constraints and
coercions. It is fully documented in the relevant classes.

=head1 AUTHOR

Dave Rolsky <autarch@urth.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Dave Rolsky.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=cut
