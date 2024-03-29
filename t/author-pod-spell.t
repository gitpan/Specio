
BEGIN {
  unless ($ENV{AUTHOR_TESTING}) {
    require Test::More;
    Test::More::plan(skip_all => 'these tests are for testing by the author');
  }
}

use strict;
use warnings;
use Test::More;

# generated by Dist::Zilla::Plugin::Test::PodSpelling 2.006002
use Test::Spelling 0.12;
use Pod::Wordlist;


add_stopwords(<DATA>);
all_pod_files_spelling_ok( qw( bin lib  ) );
__DATA__
API
ClassName
Coercions
MUTC
PARAMETERIZABLE
PayPal
Rolsky
SPECIO
ScalarRef
Specio
Throwable
boolification
coercions
de
distro
globification
inlinable
inline
isa
namespace
parameterizable
parameterization
parameterized
reimplementation
sigils
subtype
subtypes
DROLSKY
DROLSKY's
Rolsky's
Dave
autarch
lib
Constraint
ObjectDoes
Declare
ObjectCan
DeclaredAt
AnyIsa
AnyDoes
OO
Role
IsaType
CanType
Parameterizable
Helpers
Exception
Simple
Coercion
TypeChecks
Registry
Inlinable
Interface
Enum
ObjectIsa
Parameterized
DoesType
Library
Builtins
AnyCan
Exporter
