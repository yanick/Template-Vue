package Example::Item;

=begin template
    <li v-if="$_{label} ne 'me_too'">{{ label }} </li>
=end template

=cut

use Moose;

has label => (
    traits => [ 'Prop' ],
    is     => 'ro',
);

1;

