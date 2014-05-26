package Specio::Constraint::Role::CanType;
$Specio::Constraint::Role::CanType::VERSION = '0.10';
use strict;
use warnings;

use Lingua::EN::Inflect qw( PL_N WORDLIST );
use Scalar::Util qw( blessed );
use Storable qw( dclone );

use Role::Tiny;

use Specio::Constraint::Role::Interface;
with 'Specio::Constraint::Role::Interface';

{
    my $attrs = dclone( Specio::Constraint::Role::Interface::_attrs() );

    for my $name (qw( parent _inline_generator )) {
        $attrs->{$name}{init_arg} = undef;
        $attrs->{$name}{builder} = '_build_' . ( $name =~ s/^_//r );
    }

    $attrs->{methods} = {
        isa      => 'ArrayRef',
        required => 1,
    };

    sub _attrs {
        return $attrs;
    }
}

sub _wrap_message_generator {
    my $self      = shift;
    my $generator = shift;

    my @methods = @{ $self->methods() };

    $generator //= sub {
        my $description = shift;
        my $value       = shift;

        my $class = blessed $value;
        $class ||= $value;

        my @missing = grep { !$value->can($_) } @methods;

        my $noun = PL_N( 'method', scalar @missing );

        return
              $class
            . ' is missing the '
            . WORDLIST( map { "'$_'" } @missing ) . q{ }
            . $noun;
    };

    my $d = $self->_description();

    return sub { $generator->( $d, @_ ) };
}

1;

# ABSTRACT: Provides a common implementation for Specio::Constraint::AnyCan and Specio::Constraint::ObjectCan

__END__

=pod

=encoding UTF-8

=head1 NAME

Specio::Constraint::Role::CanType - Provides a common implementation for Specio::Constraint::AnyCan and Specio::Constraint::ObjectCan

=head1 VERSION

version 0.10

=head1 DESCRIPTION

See L<Specio::Constraint::AnyCan> and L<Specio::Constraint::ObjectCan> for details.

=head1 AUTHOR

Dave Rolsky <autarch@urth.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2014 by Dave Rolsky.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=cut
