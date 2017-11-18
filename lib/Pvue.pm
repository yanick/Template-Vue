package Pvue {

use Path::Tiny;
use Module::Info;

use Moose::Role;

use Template::Mustache::Trait;

use MooseX::ClassAttribute;

use experimental 'signatures';

has template => (
    is => 'ro',
    lazy => 1,
    default => sub($self) {
        my $file = Module::Info->new_from_module($self->meta->name)->file or die;
        return join '',
            grep { !/^=(begin|end|cut)/ }
            grep { 
            /^=begin\s+template\s*$/../^=(?:end\s+template|cut)\s*$/ } path($file)->lines;

    },
);

has _mustache => (
    is => 'ro',
    traits => [ 'Mustache' ],
    lazy => 1,
    default => sub($self) { $self->template },
    handles => { render_mustache => 'render' },
);

use Web::Query::LibXML;
use experimental 'postderef';
sub process_directives( $self, $doc, @context ) {
    $DB::single = 1;
    @context = ( $self ) unless @context;
            use DDP; p @context;
    $doc = Web::Query::LibXML->new( $doc, { indent => '  ' }) unless ref $doc;

    # do the 'v-for'
    # TODO have to think about v-fors in v-fors
    $doc->find( '[v-for]' )->each( sub{
        my @items = Template::Mustache::resolve_context( $_->attr('v-for'), \@context )->@*;

        my $block = $_;
        $block->attr('v-for' => undef);

        my $new = join '', map {  
            $self->process_directives( $block->clone->as_html, { item => $_ }, @context );
        } @items;
        $block->after($new);
        $block->detach;
        
    });

    # do the 'v-if'

    #  do the ':extrapolation'
    $doc->find('.')->and_back->each( sub {
        my $elt = $_;
        my @attrs = map { $_->all_attr } $_->{trees}->@*;
        for my $attr ( @attrs ) {
            next unless $attr =~ s/^://;
            $DB::single = 1;
            my $v = $elt->attr( ':'.$attr);
            warn $doc->as_html;
            $elt->attr( ':'.$attr => undef );
            $elt->attr( $attr => Template::Mustache::resolve_context( 
                $v,  \@context
            ));
        }
    });

    # process sub-components

    for my $component ( $self->components->@* ) {
        my $name = lc $component =~ s/.*:://r;
        $doc->find($name)->each(sub{
            die $_;
        });
    }


    $doc->as_html;
}


sub render($self) {
    my $mustached = $self->render_mustache;

    my $directived = $self->process_directives( $mustached );

    $directived;
}

}


package Pvue::Prop {

use Moose::Util;
use Moose::Role;

Moose::Util::meta_attribute_alias('Prop');

}


1;
