package Pvue {

use Moose::Role;

use MooseX::ClassAttribute;

use experimental 'signatures';

use Path::Tiny;
use Module::Info;

class_has template => (
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



sub render($self) {
    $self->template;

}

}


package Pvue::Prop {

use Moose::Util;
use Moose::Role;

Moose::Util::meta_attribute_alias('Prop');

}


1;
