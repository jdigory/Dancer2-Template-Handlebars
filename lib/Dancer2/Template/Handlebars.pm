package Dancer2::Template::Handlebars;
# ABSTRACT: Text::Handlebars engine for Dancer2
$Dancer2::Template::Handlebars::VERSION = '0.0.1';

use Moo;
use Carp qw/croak/;
use Dancer2::Core::Types;
use Text::Handlebars;
use File::Spec::Functions qw(abs2rel file_name_is_absolute);

with 'Dancer2::Core::Role::Template';

has '+default_tmpl_ext' => (
    default => sub { 'hbs' }
);
has '+engine' => (
    isa => InstanceOf['Text::Handlebars']
);
has helpers => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_helpers',
);

sub _build_helpers {
    my $self = shift;
    my %helpers;
    #...
    return \%helpers;
}

sub _build_engine {
    Text::Handlebars->new( %{ $_[0]->config }, helpers => $_[0]->helpers );
}

sub render {
    my ( $self, $template, $tokens ) = @_;

    ( ref $template || -f $template )
        or croak "$template is not a regular file or reference.";

    my $content = eval {
        if (ref $template eq 'SCALAR') {
            $self->engine->render_string( $$template, $tokens )
                or die "Could not process template string '$template'";
        }
        else {
            my $rel_path = file_name_is_absolute($template)
                ? abs2rel($template, $self->config->{location})
                : $template;
            $self->engine->render( $rel_path, $tokens )
                or die "Could not process template file '$template'";
        }
    };

    $@ and croak $@;

    return $content;
}

1;
