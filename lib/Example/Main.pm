package Example::Main;

=begin template

<div>
    <h1>{{ title }}</h1>

    <ul>
        <Item 
            v-for="item in items" 
            v-if="item ne 'skip_me'" 
            :label="item"  
        />
    </ul>
</div>

=cut

use Template::Vue;

components 'Example::Item';

props qw/ title items /;

1;
