package Example::Main;

=begin template
<div>
    <h1>{{ title }}</h1>

    <ul>
        <Item v-for="items" 
            v-if="$item ne 'skip_me'" :label="item"  />
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
