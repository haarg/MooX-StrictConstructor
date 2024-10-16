# NAME

MooX::StrictConstructor - Make your Moo-based object constructors blow up on unknown attributes

# SYNOPSIS

```perl
package My::Class;

use Moo;
use MooX::StrictConstructor;

has 'size' => ( is => 'rw');

# then somewhere else, when constructing a new instance
# of My::Class ...

# this blows up because color is not a known attribute
My::Class->new( size => 5, color => 'blue' );
```

# DESCRIPTION

Simply loading this module makes your constructors "strict". If your
constructor is called with an attribute init argument that your class does not
declare, then it dies. This is a great way to catch small typos.

Your application can use [Carp::Always](https://metacpan.org/pod/Carp%3A%3AAlways) to generate stack traces on `die`.
Previously all exceptions contained traces, but this could potentially leak
sensitive information, e.g.

```perl
My::Sensitive::Class->new( password => $sensitive, extra_value => 'foo' );
```

## STANDING ON THE SHOULDERS OF ...

Most of this package was lifted from [MooX::InsideOut](https://metacpan.org/pod/MooX%3A%3AInsideOut) and most of the Role
that implements the strictness was lifted from [MooseX::StrictConstructor](https://metacpan.org/pod/MooseX%3A%3AStrictConstructor).

## SUBVERTING STRICTNESS

[MooseX::StrictConstructor](https://metacpan.org/pod/MooseX%3A%3AStrictConstructor) documents two tricks for subverting strictness and
avoid having problematic arguments cause an exception: handling them in BUILD
or handle them in `BUILDARGS`.

In [MooX::StrictConstructor](https://metacpan.org/pod/MooX%3A%3AStrictConstructor) you can use a `BUILDARGS` function to handle
them, e.g. this will allow you to pass in a parameter called "spy" without
raising an exception.  Useful?  Only you can tell.

```perl
sub BUILDARGS {
    my ($self, %params) = @_;
    my $spy = delete $params{spy};
    # do something useful with the spy param
    return \%params;
}
```

Because `BUILD` methods are run after an object has been constructed and this
code runs before the object is constructed the `BUILD` trick will not work.

# BUGS/ODDITIES

## Inheritance

A class that uses [MooX::StrictConstructor](https://metacpan.org/pod/MooX%3A%3AStrictConstructor) but extends another class that
does not will not be handled properly.  This code hooks into the constructor
as it is being strung up (literally) and that happens in the parent class,
not the one using strict.

A class that inherits from a [Moose](https://metacpan.org/pod/Moose) based class will discover that the
[Moose](https://metacpan.org/pod/Moose) class's attributes are disallowed.  Given sufficient [Moose](https://metacpan.org/pod/Moose) meta
knowledge it might be possible to work around this.  I'd appreciate pull
requests and or an outline of a solution.

## Subverting strictness

[MooseX::StrictConstructor](https://metacpan.org/pod/MooseX%3A%3AStrictConstructor) documents a trick
for subverting strictness using BUILD.  This does not work here because
strictness is enforced in the early stage of object construction but the
BUILD subs are run after the objects has been built.

## Interactions with namespace::clean

[MooX::StrictConstructor](https://metacpan.org/pod/MooX%3A%3AStrictConstructor) creates a `new` method that [namespace::clean](https://metacpan.org/pod/namespace%3A%3Aclean)
will over-zealously clean.  Workarounds include using
[MooX::StrictConstructor](https://metacpan.org/pod/MooX%3A%3AStrictConstructor) **after** [namespace::autoclean](https://metacpan.org/pod/namespace%3A%3Aautoclean) or telling
[namespace::clean](https://metacpan.org/pod/namespace%3A%3Aclean) to ignore `new` with something like:

```perl
use namespace::clean -except => ['new','meta'];
```

# SEE ALSO

- [MooX::InsideOut](https://metacpan.org/pod/MooX%3A%3AInsideOut)
- [MooseX::StrictConstructor](https://metacpan.org/pod/MooseX%3A%3AStrictConstructor)

# BUGS

Please report any bugs or feature requests on the bugtracker website
[https://rt.cpan.org/Public/Dist/Display.html?Name=MooX-StrictConstructor](https://rt.cpan.org/Public/Dist/Display.html?Name=MooX-StrictConstructor)
or by email to
[bug-MooX-StrictConstructor@rt.cpan.org](mailto:bug-MooX-StrictConstructor@rt.cpan.org).

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

# AUTHOR

George Hartzell <hartzell@cpan.org>

# CONTRIBUTORS

- George Hartzell <hartzell@alerce.com>
- Graham Knop <haarg@haarg.org>
- JJ Merelo <jjmerelo@gmail.com>
- jrubinator &lt;jjrs.pam+github@gmail.com>
- mohawk2 <mohawk2@users.noreply.github.com>
- Samuel Kaufman <samuel.c.kaufman@gmail.com>
- Tim Bunce <Tim.Bunce@pobox.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by George Hartzell.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
