package Specio::Constraint::ObjectIsa;
$Specio::Constraint::ObjectIsa::VERSION = '0.11';
use strict;
use warnings;

use B ();
use Role::Tiny::With;
use Scalar::Util ();
use Specio::Library::Builtins;
use Specio::OO;

use Specio::Constraint::Role::IsaType;
with 'Specio::Constraint::Role::IsaType';

{
    my $Object = t('Object');
    sub _build_parent { $Object }
}

{
    my $_inline_generator = sub {
        my $self = shift;
        my $val  = shift;

        return
              'Scalar::Util::blessed('
            . $val . ')' . ' && '
            . $val
            . '->isa('
            . B::perlstring( $self->class ) . ')';
    };

    sub _build_inline_generator { $_inline_generator }
}

__PACKAGE__->_ooify();

1;

# ABSTRACT: A class for constraints which require an object that inherits from a specific class

__END__

=pod

=encoding UTF-8

=head1 NAME

Specio::Constraint::ObjectIsa - A class for constraints which require an object that inherits from a specific class

=head1 VERSION

version 0.11

=head1 SYNOPSIS

    my $type = Specio::Constraint::ObjectIsa->new(...);
    print $type->class();

=head1 DESCRIPTION

This is a specialized type constraint class for types which require an object
that inherits from a specific class.

=head1 API

This class provides all of the same methods as L<Specio::Constraint::Simple>,
with a few differences:

=head2 Specio::Constraint::ObjectIsa->new( ... )

The C<parent> parameter is ignored if it passed, as it is always set to the
C<Defined> type.

The C<inline_generator> and C<constraint> parameters are also ignored. This
class provides its own default inline generator subroutine reference.

This class overrides the C<message_generator> default if none is provided.

Finally, this class requires an additional parameter, C<class>. This must be a
single class name.

=head2 $object_isa->class()

Returns the class name passed to the constructor.

=head1 ROLES

This class does the L<Specio::Constraint::Role::IsaType>,
L<Specio::Constraint::Role::Interface>, L<Specio::Role::Inlinable>, and
L<MooseX::Clone> roles.

=head1 AUTHOR

Dave Rolsky <autarch@urth.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2014 by Dave Rolsky.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=cut
