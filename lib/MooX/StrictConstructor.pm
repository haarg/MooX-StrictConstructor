use strict;                     # redundant, but quiets perlcritic
use warnings;
package MooX::StrictConstructor;

# ABSTRACT: Make your Moo-based object constructors blow up on unknown attributes.

=head1 SYNOPSIS

    package My::Class;

    use Moo;
    use MooX::StrictConstructor;

    has 'size' => ( is => 'rw');

    # then somewhere else, when constructing a new instance
    # of My::Class ...

    # this blows up because color is not a known attribute
    My::Class->new( size => 5, color => 'blue' );

=head1 DESCRIPTION

Simply loading this module makes your constructors "strict". If your
constructor is called with an attribute init argument that your class does not
declare, then it dies. This is a great way to catch small typos.

Your application can use L<Carp::Always> to generate stack traces on C<die>.
Previously all exceptions contained traces, but this could potentially leak
sensitive information, e.g.

    My::Sensitive::Class->new( password => $sensitive, extra_value => 'foo' );

=head2 STANDING ON THE SHOULDERS OF ...

Most of this package was lifted from L<MooX::InsideOut> and most of the Role
that implements the strictness was lifted from L<MooseX::StrictConstructor>.

=head2 SUBVERTING STRICTNESS

L<MooseX::StrictConstructor> documents two tricks for subverting strictness and
avoid having problematic arguments cause an exception: handling them in BUILD
or handle them in C<BUILDARGS>.

In L<MooX::StrictConstructor> you can use a C<BUILDARGS> function to handle
them, e.g. this will allow you to pass in a parameter called "spy" without
raising an exception.  Useful?  Only you can tell.

   sub BUILDARGS {
       my ($self, %params) = @_;
       my $spy = delete $params{spy};
       # do something useful with the spy param
       return \%params;
   }

Because C<BUILD> methods are run after an object has been constructed and this
code runs before the object is constructed the C<BUILD> trick will not work.

=cut

use Moo 1.001000 ();    # $Moo::MAKERS support
use Moo::Role ();
use Carp ();

use Class::Method::Modifiers qw(install_modifier);

use constant
    _CON_ROLE => 'Method::Generate::Constructor::Role::StrictConstructor';

#
# The gist of this code was copied directly from Graham Knop (HAARG)'s
# MooX::InsideOut, specifically its import sub.  It has diverged a bit to
# handle goal specific differences.
#
sub import {
    my $class  = shift;
    my $target = caller;
    unless ( $Moo::MAKERS{$target} && $Moo::MAKERS{$target}{is_class} ) {
        Carp::croak("MooX::StrictConstructor can only be used on Moo classes.");
    }

    _apply_role($target);

    install_modifier($target, 'after', 'extends', sub {
        _apply_role($target);
    });
}

sub _apply_role {
    my $target = shift;
    my $con = Moo->_constructor_maker_for($target);
    Moo::Role->apply_roles_to_object($con, _CON_ROLE)
        unless Role::Tiny::does_role($con, _CON_ROLE);
}

=head1 BUGS/ODDITIES

=head2 Inheritance

A class that uses L<MooX::StrictConstructor> but extends another class that
does not will not be handled properly.  This code hooks into the constructor
as it is being strung up (literally) and that happens in the parent class,
not the one using strict.

A class that inherits from a L<Moose> based class will discover that the
L<Moose> class's attributes are disallowed.  Given sufficient L<Moose> meta
knowledge it might be possible to work around this.  I'd appreciate pull
requests and or an outline of a solution.

=head2 Subverting strictness

L<MooseX::StrictConstructor> documents a trick
for subverting strictness using BUILD.  This does not work here because
strictness is enforced in the early stage of object construction but the
BUILD subs are run after the objects has been built.

=head2 Interactions with namespace::clean

L<MooX::StrictConstructor> creates a C<new> method that L<namespace::clean>
will over-zealously clean.  Workarounds include using
L<MooX::StrictConstructor> B<after> L<namespace::autoclean> or telling
L<namespace::clean> to ignore C<new> with something like:

  use namespace::clean -except => ['new','meta'];

=head1 SEE ALSO

=for :list
* L<MooX::InsideOut>
* L<MooseX::StrictConstructor>

=cut

1;
