use strict;                     # redundant, but quiets perlcritic
use warnings;
package MooX::StrictConstructor::Role::Constructor::Base;

our $VERSION = '0.013';

use Moo::Role;

sub _check_strict {
    my ($self, $spec, $arg) = @_;
    my $captures = {
        '%MooX_StrictConstructor_attrs' => {
            map +($_ => 1),
            grep defined,
            map  $_->{init_arg},
            values %$spec,
        },
    };
    my $code = sprintf(<<'END_CODE', $arg);
    if ( my @bad = grep !exists $MooX_StrictConstructor_attrs{$_}, keys %%{%s} ) {
        require Carp;
        Carp::croak(
            "Found unknown attribute(s) passed to the constructor: " .
            join(", ", sort @bad)
        );
    }
END_CODE
    return ($code, $captures);
}

1;
__END__
