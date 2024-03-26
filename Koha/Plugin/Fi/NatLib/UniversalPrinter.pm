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
    {   name => 'nightly_cron_enabled',
        type => 'checkbox',
        default => undef,
        name_display => 'Enable nightly cronjob for MARC21 Sync',
        description => 'if you want to enable nightly cronjob for MARC21 Sync, check this box',
    },
    {   name => 'random_email',
        type => 'email',
        default => undef,
        name_display => 'Random value 1: email',
        description => 'just should be limited to email',
    },
    {   name => 'random_url',
        type => 'url',
        default => undef,
        name_display => 'Random value 2: url',
        description => 'just should be limited to url',
    },
    {   name => 'random_date',
        type => 'date',
        default => undef,
        name_display => 'Random value 3: date',
        description => 'just should be limited to date',
    },
    {   name => 'random_text',
        type => 'text',
        default => undef,
        name_display => 'Random value 4: text',
        description => '',
    },
    {   name => 'random_color',
        type => 'color',
        default => undef,
        name_display => 'Random value 5: color',
        description => '',
    },
    {   name => 'random_range',
        type => 'range',
        default => undef,
        name_display => 'Random value 6: range',
        description => '',
    },
    {   name => 'random_select',
        type => 'select',
        default => undef,
        options => [
            { value => '1', label => '24 tuntia hieman suolaista Kiralohi' },
            { value => '2', label => 'Lohikeittö' },
            { value => '3', label => 'Maito' },
            { value => '4', label => 'Sushi' },
            { value => '5', label => 'Peruna leipää' },
        ],
        name_display => 'Random value 7: select',
        description => 'What is your favorite food?',
    },
    {   name => 'random_radiobuttons',
        type => 'radiobuttons',
        default => undef,
        options => [
            { value => '1', label => '24 tuntia hieman suolaista Kiralohi' },
            { value => '2', label => 'Lohikeittö' },
            { value => '3', label => 'Maito' },
            { value => '4', label => 'Sushi' },
            { value => '5', label => 'Peruna leipää' },
        ],
        name_display => 'Random value 9: radiobutton',
        description => 'What is your favorite food?',
    },
    {   name => 'random_textarea',
        type => 'textarea',
        default => undef,
        name_display => 'Random value 8: textarea',
        description => '',
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
