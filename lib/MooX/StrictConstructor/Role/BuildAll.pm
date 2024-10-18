use strict;                     # redundant, but quiets perlcritic
use warnings;
package MooX::StrictConstructor::Role::BuildAll;

our $VERSION = '0.014';

use Moo::Role;

has _constructor_generator => (
    is => 'rw',
    weaken => 1,
);

around buildall_body_for => sub {
    my ($orig, $self, $into, $me, $args, @extra) = @_;

    my $con = $self->_constructor_generator;
    my $fake_BUILD = $con->can('_fake_BUILD');
    my $real_build = ! do {
        no strict 'refs';
        defined &{"${into}::BUILD"} && \&{"${into}::BUILD"} == $fake_BUILD;
    };

    my $code = '';
    if ($real_build) {
        $code .= $self->$orig($into, $me, $args, @extra);
    }
    my $arg = $args =~ /^\$\w+(?:\[[0-9]+\])?$/ ? $args : "($args)[0]";
    $code .= "do {\n" . $con->_cap_call($con->_check_strict($con->all_attribute_specs, $arg)) . "},\n";
    return $code;
};

1;
__END__
