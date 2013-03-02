package Specio::Constraint::Role::CanType;
{
  $Specio::Constraint::Role::CanType::VERSION = '0.06';
}

use strict;
use warnings;

use Lingua::EN::Inflect qw( PL_N WORDLIST );
use Scalar::Util qw( blessed );

use Moose::Role;

with 'Specio::Constraint::Role::Interface' =>
    { -excludes => ['_wrap_message_generator'] };

has methods => (
    is       => 'ro',
    isa      => 'ArrayRef[Str]',
    required => 1,
);

override BUILDARGS => sub {
    my $self = shift;

    my $p = super();

    if ( defined $p->{can} && !ref $p->{can} ) {
        $p->{can} = [ $p->{can} ];
    }

    return $p;
};

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

=head1 NAME

Specio::Constraint::Role::CanType - Provides a common implementation for Specio::Constraint::AnyCan and Specio::Constraint::ObjectCan

=head1 VERSION

version 0.06

=head1 DESCRIPTION

See L<Specio::Constraint::AnyCan> and L<Specio::Constraint::ObjectCan> for details.

=head1 AUTHOR

Dave Rolsky <autarch@urth.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Dave Rolsky.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=cut
