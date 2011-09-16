package Pod::Weaver::Section::Contributors;
use Moose;
    with 'Pod::Weaver::Role::Section';
use Moose::Autobox;

use Pod::Elemental::Element::Nested;
use Pod::Elemental::Element::Pod5::Verbatim;

sub weave_section {
    my ($self, $document, $input) = @_;

    return unless $input->{contributors};

    my $multiple_contrbutors = $input->{contributors}->length > 1;
    my $name = $multiple_contrbutors ? 'CONTRIBUTORS' : 'CONTRIBUTOR';

    my $contributors = $input->{contributors}->map(sub {
        Pod::Elemental::Element::Pod5::Ordinary->new({
        content => $_,
        }),
    });

    $document->children->push(
        Pod::Elemental::Element::Nested->new({
        type     => 'command',
        command  => 'head1',
        content  => $name,
        children => $contributors,
        }),
    );
}

no Moose;
1;

__END__
