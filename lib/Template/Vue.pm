package Template::Vue;

use Path::Tiny;
use Module::Info;

use Moose::Role;

use Template::Mustache::Trait;

use experimental 'signatures';

has components => (
    is => 'ro',
    default => sub { [] },
);

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
    traits => [ 'Mustache' ],
    handles => { render_mustache => 'render' },
);

use Web::Query::LibXML;
use experimental 'postderef';
sub process_directives( $self, $doc, @context ) {
    @context = ( $self ) unless @context;
    $doc = Web::Query::LibXML->new( $doc, { indent => '  ' }) unless ref $doc;

    # do the 'v-for'
    # TODO have to think about v-fors in v-fors
    $doc->find( '[v-for]' )->each( sub{
        my( $item, $key ) = split /\s+in\s+/, $_->attr('v-for'), 2;
        my @items = Template::Mustache::resolve_context( $key, \@context )->@*;

        my $block = $_;
        $block->attr('v-for' => undef);

        my $new = join '', map {  
            $self->process_directives( $block->clone->as_html, { $item => $_ }, @context );
        } @items;
        $block->after($new);
        $block->detach;
        
    });

    # do the 'v-if'
    $doc->find('.')->and_back->filter( '[v-if]' )->each( sub{
        my $block = $_;
        my($variable,$rest) = split / /, $_->attr('v-if'), 2; 
        $block->attr('v-if' => undef);

        my $bool = eval qq{
            Template::Mustache::resolve_context( '$variable', \\\@context )
            $rest
        };
        warn $@ if $@;
        warn $bool;
        $block->remove unless $bool;
        
    });

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

    for my $component ( eval {  $self->components->@* } ) {
        my $name = lc $component =~ s/.*:://r;
        $doc->find($name)->each(sub{
            my $elt = $_;
            use Module::Runtime qw/ use_module /;
            my %attr = map { $_ => $elt->attr($_) } $_->{trees}[0]->all_attr;
            my $sub = use_module($component)->new( %attr );
            $elt->after($sub->render);
            $elt->detach;
        });
    }

    $doc->as_html;
}


sub render($self) {
    my $mustached = $self->render_mustache;

    my $directived = $self->process_directives( $mustached );

    $directived;
}


1;
