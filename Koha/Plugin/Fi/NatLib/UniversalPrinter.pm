package Koha::Plugin::Fi::NatLib::UniversalPrinter;
use Modern::Perl; use utf8; use open qw(:utf8);
use base qw(Koha::Plugins::Base);

use Koha::Plugin::Fi::NatLib::UniversalPrinter::App;


## ----------------------------------------
## Plugin description metadata
## ----------------------------------------

our $VERSION = "{VERSION}";
our $metadata = {
    name            => 'Universal Printer',
    author          => 'Kansalliskirjasto Koha Dev Team / Andrii, Slava, Petro',
    description     => 'Print anything in any way you want',
    homepage        => 'https://github.com/NatLibFi/koha-plugin-universal-printer',
    date_authored   => '2024-03-25',
    date_updated    => '1900-01-01',
    minimum_version => '23.1100000',
    maximum_version => undef,
    version         => $VERSION,
};


## ----------------------------------------
## Configuration screen values
## (each plugin should have a few)
## ----------------------------------------

our $configuration = [
    {   name => 'template',
        type => 'textarea',
        default => undef,
        name_display => 'template',
        description => 'asdfewr',
    },
    {   name => 'style',
        type => 'textarea',
        default => undef,
        name_display => 'style',
        description => 'wergwe',
    },
];


## ----------------------------------------
## Which methods we have acrive in our plugin
## ----------------------------------------
## just have it here declaured, but they then subcalled to App-> methods to have modularization.

sub install   { my $self = shift; $self->{app}->preconfig($self); return $self->{app}->init_install_plugin(@_); }
sub uninstall { my $self = shift; $self->{app}->preconfig($self); return $self->{app}->init_uninstall_plugin(@_); }
sub upgrade   { my $self = shift; $self->{app}->preconfig($self);
    Koha::Caches->get_instance('plugins')->clear_from_cache($self->{config_cache_key});
    return $self->{app}->init_upgrade_plugin(@_); }

sub cronjob_nightly { return shift->{app}->cronjob_nightly(@_); }

sub configure { return shift->{app}->configure_plugin(@_); }
sub report    { return shift->{app}->runtime_report_mode(@_); }
sub tool      { return shift->{app}->runtime_tool_mode(@_); }

sub intranet_catalog_biblio_enhancements_toolbar_button { return shift->{app}->intra_biblio_tbbutton(@_); }


## ----------------------------------------
## Predefined new method, no need to change
## ----------------------------------------

sub new {
    my ( $class, $args ) = @_;
    my $self = $class->SUPER::new({ %{$args//{}},
        metadata => { %$metadata, class => $class },
        app => Koha::Plugin::Fi::NatLib::UniversalPrinter::App->new({ configuration => $configuration }),
    });
    $self->{app}->preconfig($self);
    return $self;
}

1;
