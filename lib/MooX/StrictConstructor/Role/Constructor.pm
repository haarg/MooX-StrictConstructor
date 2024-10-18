use strict;                     # redundant, but quiets perlcritic
use warnings;
package MooX::StrictConstructor::Role::Constructor;

our $VERSION = '0.014';

use Moo::Role;

with 'MooX::StrictConstructor::Role::Constructor::Base';

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
