package Example::Item;

=begin template
    <li v-if="label ne 'me_too'">{{ label }}</li>
=cut

use Moose;
with 'Template::Vue';

has label => ( is => 'ro' );

1;

