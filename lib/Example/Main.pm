package Example::Main;

=begin template
<div>
    <h1>{{ title }}<h1>

    <ul>
        <li v-for="items" v-if="$_->{label} ne 'skip_me'" :label="$_->{label}"  />
    </ul>
</div>

=end template

=cut

use Moose;
with 'Pvue';

has components => (
    is => 'ro',
    default => sub { [ qw/ Example::Item / ] },
);

has title => ( 
    traits => [ 'Prop' ],
    is => 'ro',
);

has items => ( 
    traits => [ 'Prop' ],
    is => 'ro',
);


1;
