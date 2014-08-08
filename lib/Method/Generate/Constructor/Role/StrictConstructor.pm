use strict;                     # redundant, but quiets perlcritic
package Method::Generate::Constructor::Role::StrictConstructor;

# ABSTRACT: a role to make Moo constructors strict.

=head1 DESCRIPTION

This role wraps L<Method::Generate::Constructor/_assign_new> with a bit of code
that ensures that all arguments passed to the constructor are valid init_args
for the class.

=head2 STANDING ON THE SHOULDERS OF ...

This code would not exist without the examples in L<MooX::InsideOut> and
L<MooseX::StrictConstructor>.

=cut

use Moo::Role;

has _buildall_generator => ( is => 'rw' );

around buildall_generator => sub {
  my ($orig, $self, @args) = @_;
  my $gen = $self->_buildall_generator;
  return $gen
    if $gen;
  $gen = Moo::Role->apply_roles_to_object($self->$orig(@args),
    'Method::Generate::BuildAll::Role::StrictConstructor'
  );
  $gen->_constructor_generator($self);
  return $self->_buildall_generator($gen);
};

*_fake_BUILD = *Method::Generate::BuildAll::Role::StrictConstructor::_fake_BUILD;

around generate_method => sub {
  my ($orig, $self, $into, @args) = @_;
  no strict 'refs'; ## no critic
  # this ensures BuildAll generation will always be done, but allows us to
  # identify when the BUILD calls aren't needed.
  local *{"${into}::BUILD"} = \&_fake_BUILD if !$into->can('BUILD');
  $self->$orig($into, @args);
};

=head1 SEE ALSO

=for :list
* L<MooX::InsideOut>
* L<MooseX::StrictConstructor>

=cut

1;
