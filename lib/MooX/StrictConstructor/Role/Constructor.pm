use strict;                     # redundant, but quiets perlcritic
use warnings;
package MooX::StrictConstructor::Role::Constructor;

our $VERSION = '0.013';

use Moo::Role;

sub _check_strict {
    my ($self, $spec, $arg) = @_;
    my %captures = (
        '%MooX_StrictConstructor_attrs' => {
            map +($_ => 1),
            grep defined,
            map  $_->{init_arg},
            values %$spec,
        },
    );
    my $code = sprintf(<<'END_CODE', $arg);
    if ( my @bad = grep !exists $MooX_StrictConstructor_attrs{$_}, keys %%{%s} ) {
        require Carp;
        Carp::croak(
            "Found unknown attribute(s) passed to the constructor: " .
            join(", ", sort @bad)
        );
    }
END_CODE
    return ($code, \%captures);
}

around _check_required => sub {
    my ($orig, $self, $spec, @rest) = @_;
    my $code = $self->$orig($spec, @rest);
    $code .= $self->_cap_call($self->_check_strict($spec, '$args'));
    return $code;
};

1;
__END__

=head1 NAME

MooX::StrictConstructor::Role::Constructor - a role to make Moo constructors strict

=head1 DESCRIPTION

This role wraps L<Method::Generate::Constructor> with a bit of code
that ensures that all arguments passed to the constructor are valid init_args
for the class.

=head2 STANDING ON THE SHOULDERS OF ...

This code would not exist without the examples in L<MooX::InsideOut> and
L<MooseX::StrictConstructor>.

=head1 SEE ALSO

=over 4

=item *

L<MooseX::StrictConstructor>

=back

=cut
