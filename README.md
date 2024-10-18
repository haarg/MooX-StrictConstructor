# NAME

MooX::StrictConstructor - Make your Moo-based object constructors blow up on unknown attributes

# SYNOPSIS

```perl
package My::Class;

use Moo;
use MooX::StrictConstructor;

has 'size' => ( is => 'rw' );

# then somewhere else, when constructing a new instance
# of My::Class ...

# this blows up because color is not a known attribute
My::Class->new( size => 5, color => 'blue' );
```

# DESCRIPTION

Simply loading this module makes your constructors "strict". If your
constructor is called with an attribute init argument that your class does not
declare, then it dies. This is a great way to catch small typos.

## STANDING ON THE SHOULDERS OF ...

This module was inspired by [MooseX::StrictConstructor](https://metacpan.org/pod/MooseX%3A%3AStrictConstructor), and includes some
implementation details taken from it.

## SUBVERTING STRICTNESS

There are two options for subverting the strictness to handle problematic
arguments. They can be handled in `BUILDARGS` or in `BUILD`.

You can use a `BUILDARGS` function to handle them, e.g. this will allow you
to pass in a parameter called "spy" without raising an exception.  Useful?
Only you can tell.

```perl
sub BUILDARGS {
    my ($self, %params) = @_;
    my $spy = delete $params{spy};
    # do something useful with the spy param
    return \%params;
}
```

It is also possible to handle extra parameters in `BUILD`. This requires
the strictness check to be performed at the end of object construction rather
than at the beginning.

```perl
use MooX::StrictConstuctor -late;

sub BUILD {
    my ($self, $params) = @_;
    if ( my $spy = delete $params->{spy} ) {
        # do something useful
    }
}
```

When using this option, the object will be fully constructed before checking
the parameters, and a failure will cause the destructor to be run.

# BUGS/ODDITIES

## Inheritance

A class that uses [MooX::StrictConstructor](https://metacpan.org/pod/MooX%3A%3AStrictConstructor) but extends a non-Moo class will
not be handled properly.  This code hooks into the constructor as it is being
strung up (literally) and that happens in the parent class, not the one using
strict.

A class that inherits from a [Moose](https://metacpan.org/pod/Moose) based class will discover that the
[Moose](https://metacpan.org/pod/Moose) class's attributes are disallowed.  Given sufficient [Moose](https://metacpan.org/pod/Moose) meta
knowledge it might be possible to work around this.  I'd appreciate pull
requests and or an outline of a solution.

## Interactions with namespace::clean

[MooX::StrictConstructor](https://metacpan.org/pod/MooX%3A%3AStrictConstructor) creates a `new` method that [namespace::clean](https://metacpan.org/pod/namespace%3A%3Aclean)
will over-zealously clean.  Workarounds include using [namespace::autoclean](https://metacpan.org/pod/namespace%3A%3Aautoclean),
using [MooX::StrictConstructor](https://metacpan.org/pod/MooX%3A%3AStrictConstructor) **after** [namespace::clean](https://metacpan.org/pod/namespace%3A%3Aclean) or telling
[namespace::clean](https://metacpan.org/pod/namespace%3A%3Aclean) to ignore `new` with something like:

```perl
use namespace::clean -except => ['new'];
```

# SEE ALSO

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
