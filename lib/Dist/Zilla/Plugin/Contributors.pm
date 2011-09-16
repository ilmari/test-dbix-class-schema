package Dist::Zilla::Plugin::Contributors;
use Moose;
use Moose::Autobox;
use List::MoreUtils qw(any);
use Pod::Weaver 3.100710; # logging with proxies
with(
  'Dist::Zilla::Role::FileMunger',
  'Dist::Zilla::Role::FileFinderUser' => {
    default_finders => [ ':InstallModules', ':ExecFiles' ],
  },
);

with 'Pod::Elemental::PerlMunger';

use Pod::Weaver::Section::Contributors;

has config_plugin => (
  is  => 'ro',
  isa => 'Str',
);

no Moose;

use namespace::autoclean;

use PPI;
use Pod::Elemental;
use Pod::Elemental::Transformer::Pod5;
use Pod::Elemental::Transformer::Nester;
use Pod::Elemental::Selectors -all;
use Pod::Weaver::Config::Assembler;

sub weaver {
    my $self = shift;
    
    my @files = glob($self->zilla->root->file('weaver.*'));
    
    my $arg = {
        root        => $self->zilla->root,
        root_config => { logger => $self->logger },
    };
    
    if ($self->config_plugin) {
warn 'plugin';
        my $assembler = Pod::Weaver::Config::Assembler->new;
    
        my $root = $assembler->section_class->new({ name => '_' });
        $assembler->sequence->add_section($root);
    
        $assembler->change_section( $self->config_plugin );
        $assembler->end_section;
    
        return Pod::Weaver->new_from_config_sequence($assembler->sequence, $arg);
    } elsif (@files) {
warn 'files';
        return Pod::Weaver->new_from_config($arg);
    } else {
warn 'fallthrough';
        return Pod::Weaver->new_with_default_config($arg);
    }
}

sub munge_files {
    my $self = shift;
    $self->munge_file($_) for @{ $self->found_files };
}

sub munge_file {
  my ($self, $file) = @_;
 
  $self->log_debug([ 'weaving pod in %s', $file->name ]);
  warn (sprintf( 'weaving pod in %s', $file->name ));
  $self->munge_pod($file);
  return;
}

sub munge_perl_string {
    my ($self, $doc, $arg) = @_;
    my $weaver  = $self->weaver;
    my $new_doc = $weaver->weave_document({
        %$arg,
        pod_document => $doc->{pod},
        ppi_document => $doc->{ppi},
    });
    
    return {
        pod => $new_doc,
        ppi => $doc->{ppi},
    }
}

sub munge_pod {
    my ($self, $file) = @_;

    my $content     = $file->content;
    my $new_content = $self->munge_perl_string(
        $file->content,
        {
            contributors => $self->zilla->contributors,
        },
    );
die $new_content;
    $file->content($new_content);

    return;
}
 
__PACKAGE__->meta->make_immutable;
no Moose;
1;
 
__END__
