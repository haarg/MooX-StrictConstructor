use strict;                     # redundant, but quiets perlcritic
package Method::Generate::BuildAll::Role::StrictConstructor;
use Moo::Role;

has _constructor_generator => (is => 'rw', weaken => 1);

sub _fake_BUILD {}

around buildall_body_for => sub {
  my ($orig, $self, $into, $me, $args, @extra) = @_;

  my $con = $self->_constructor_generator;
  my $real_build = ! do {
    no strict 'refs'; ## no critic
    defined &{"${into}::BUILD"} && \&{"${into}::BUILD"} == \&_fake_BUILD;
  };

  my $code = '';
  if ($real_build) {
    $code .= $self->$orig($into, $me, $args, @extra);
  }
  my $arg = $args =~ /^\$\w+$/ ? $args : "($args)[0]";
  $code .=
    '    if ( my @bad = grep { ! exists $MooX_StrictConstructor_attrs{$_} } keys %{'.$arg.'} ) {'."\n"
    .'      Carp::croak("Found unknown attribute(s) passed to the constructor: " .'."\n"
    .'        join(", ", sort @bad));'."\n"
    .'    }'."\n";

  my %captures = (
    '%MooX_StrictConstructor_attrs' => {
      map +($_ => 1),
      grep defined,
      map  $_->{init_arg},
      values %{ $con->all_attribute_specs }
    },
  );

  $con->_cap_call($code, \%captures);
};

1;
__END__
