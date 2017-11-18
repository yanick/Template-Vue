package Example::Item;

=begin template
    <li v-if="label ne 'me_too'">{{ label }}</li>
=end template

=cut

use Moose;
with 'Pvue';

has label => (
    traits => [ 'Prop' ],
    is     => 'ro',
);

1;

