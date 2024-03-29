package Specio::OO;
$Specio::OO::VERSION = '0.11';
use strict;
use warnings;

use B qw( perlstring );
use Carp qw( confess );
use Eval::Closure qw( eval_closure );
use Exporter qw( import );
use Scalar::Util qw( blessed weaken );
use mro ();
use Specio::TypeChecks qw(
    does_role
    is_ArrayRef
    is_ClassName
    is_CodeRef
    is_HashRef
    is_Int
    is_Str
    isa_class
);
use Storable qw( dclone );

our @EXPORT = qw(
    clone
    _ooify
);

sub _ooify {
    my $class = shift;

    my $attrs = $class->_attrs();
    for my $name ( sort keys %{$attrs} ) {
        my $attr = $attrs->{$name};

        _inline_reader( $class, $name, $attr );
        _inline_predicate( $class, $name, $attr );
    }

    _inline_constructor($class);
}

sub _inline_reader {
    my $class = shift;
    my $name  = shift;
    my $attr  = shift;

    my $reader;
    if ( $attr->{lazy} && ( my $builder = $attr->{builder} ) ) {
        $reader = "sub { \$_[0]->{$name} ||= \$_[0]->$builder(); }";
    }
    else {
        $reader = "sub { \$_[0]->{$name} }";
    }

    {
        no strict 'refs';
        *{ $class . '::' . $name } = eval_closure(
            source      => $reader,
            description => $class . '->' . $name,
        );
    }
}

sub _inline_predicate {
    my $class = shift;
    my $name  = shift;
    my $attr  = shift;

    return unless $attr->{predicate};

    my $predicate = "sub { exists \$_[0]->{$name} }";

    {
        no strict 'refs';
        *{ $class . '::' . $attr->{predicate} } = eval_closure(
            source      => $predicate,
            description => $class . '->' . $attr->{predicate},
        );
    }
}

sub _inline_constructor {
    my $class = shift;

    my @build_subs;
    for my $class ( @{ mro::get_linear_isa($class) } ) {
        {
            no strict 'refs';
            push @build_subs, $class . '::BUILD'
                if defined &{ $class . '::BUILD' };
        }
    }

    my $constructor = <<'EOF';
sub {
    my $class = shift;

    my %p = do {
        if ( @_ == 1 ) {
            if ( ref $_[0] eq 'HASH' ) {
                %{ shift() };
            }
            else {
                Specio::OO::_constructor_confess(
                    Specio::OO::_bad_args_message( $class, @_ ) );
            }
        }
        else {
            Specio::OO::_constructor_confess(
                Specio::OO::_bad_args_message( $class, @_ ) )
                if @_ % 2;
            @_;
        }
    };

    my $self = bless {}, $class;

EOF

    my $attrs = $class->_attrs();
    for my $name ( sort keys %{$attrs} ) {
        my $attr = $attrs->{$name};
        my $key_name = $attr->{init_arg} // $name;

        if ( $attr->{required} ) {
            $constructor .= <<"EOF";
    Specio::OO::_constructor_confess(
        "$class->new() requires a $key_name argument.")
        unless exists \$p{$key_name};
EOF
        }

        if ( $attr->{builder} && !$attr->{lazy} ) {
            my $builder = $attr->{builder};
            $constructor .= <<"EOF";
    \$p{$key_name} = $class->$builder() unless exists \$p{$key_name};
EOF
        }

        if ( $attr->{isa} ) {
            my $validator;
            if ( Specio::TypeChecks->can( 'is_' . $attr->{isa} ) ) {
                $validator = 'Specio::TypeChecks::is_' . $attr->{isa} . "( \$p{$key_name} )";
            }
            else {
                my $quoted_class = perlstring( $attr->{isa});
                $validator = "Specio::TypeChecks::isa_class( \$p{$key_name}, $quoted_class )";
            }

            $constructor .= <<"EOF";
    if ( exists \$p{$key_name} && !$validator ) {
        Carp::confess(
            Specio::OO::_bad_value_message(
                "The value you provided to $class->new() for $key_name is not a valid $attr->{isa}.",
                \$p{$key_name},
            )
        );
    }
EOF
        }

        if ( $attr->{does} ) {
            my $quoted_role = perlstring($attr->{does});
            $constructor .= <<"EOF";
    if ( exists \$p{$key_name} && !Specio::TypeChecks::does_role( \$p{$key_name}, $quoted_role ) ) {
        Carp::confess(
            Specio::OO::_bad_value_message(
                "The value you provided to $class->new() for $key_name does not do the $attr->{does} role.",
                \$p{$key_name},
            )
        );
    }
EOF
        }

        if ( $attr->{weak_ref} ) {
            $constructor .= "    Scalar::Util::weaken( \$p{$key_name} );\n";
        }

        $constructor .= "    \$self->{$name} = \$p{$key_name} if exists \$p{$key_name};\n";

        $constructor .= "\n";
    }

    $constructor .= '    $self->' . $_ . "(\\%p);\n" for @build_subs;
    $constructor .= <<'EOF';

    return $self;
}
EOF

    {
        no strict 'refs';
        *{ $class . '::new' } = eval_closure(
            source      => $constructor,
            description => $class . '->new',
        );
    }
}

sub _constructor_confess {
    local $Carp::CarpLevel = $Carp::CarpLevel + 1;
    confess shift;
}

sub _bad_args_message {
    my $class = shift;

    return
        "$class->new() requires either a hashref or hash as arguments. You passed "
        . Devel::PartialDump->new()->dump(@_);
}

sub _bad_value_message {
    my $message = shift;
    my $value   = shift;

    return
          $message
        . ' You passed '
        . Devel::PartialDump->new()->dump($value);
}

sub clone {
    my $self = shift;

    my %new;
    for my $key ( keys %{$self} ) {
        my $value = $self->{$key};

        $new{$key}
            = blessed $value           ? $value->clone()
            : ( ref $value eq 'CODE' ) ? $value
            : ref $value               ? dclone($value)
            :                            $value;
    }

    return bless \%new, ( ref $self );
}

1;

# ABSTRACT: A painfully poor reimplementation of Moo(se)

__END__

=pod

=encoding UTF-8

=head1 NAME

Specio::OO - A painfully poor reimplementation of Moo(se)

=head1 VERSION

version 0.11

=head1 DESCRIPTION

Specio can't depend on Moo or Moose, so this module provides a terrible
reimplementation of a small slice of their features.

=for Pod::Coverage .*

=head1 AUTHOR

Dave Rolsky <autarch@urth.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2014 by Dave Rolsky.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=cut
