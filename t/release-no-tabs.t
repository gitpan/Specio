
BEGIN {
  unless ($ENV{RELEASE_TESTING}) {
    require Test::More;
    Test::More::plan(skip_all => 'these tests are for release candidate testing');
  }
}

use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::Test::NoTabs 0.06

use Test::More 0.88;
use Test::NoTabs;

my @files = (
    'lib/Specio.pm',
    'lib/Specio/Coercion.pm',
    'lib/Specio/Constraint/AnyCan.pm',
    'lib/Specio/Constraint/AnyDoes.pm',
    'lib/Specio/Constraint/AnyIsa.pm',
    'lib/Specio/Constraint/Enum.pm',
    'lib/Specio/Constraint/ObjectCan.pm',
    'lib/Specio/Constraint/ObjectDoes.pm',
    'lib/Specio/Constraint/ObjectIsa.pm',
    'lib/Specio/Constraint/Parameterizable.pm',
    'lib/Specio/Constraint/Parameterized.pm',
    'lib/Specio/Constraint/Role/CanType.pm',
    'lib/Specio/Constraint/Role/DoesType.pm',
    'lib/Specio/Constraint/Role/Interface.pm',
    'lib/Specio/Constraint/Role/IsaType.pm',
    'lib/Specio/Constraint/Simple.pm',
    'lib/Specio/Declare.pm',
    'lib/Specio/DeclaredAt.pm',
    'lib/Specio/Exception.pm',
    'lib/Specio/Exporter.pm',
    'lib/Specio/Helpers.pm',
    'lib/Specio/Library/Builtins.pm',
    'lib/Specio/OO.pm',
    'lib/Specio/Registry.pm',
    'lib/Specio/Role/Inlinable.pm',
    'lib/Specio/TypeChecks.pm'
);

notabs_ok($_) foreach @files;
done_testing;
