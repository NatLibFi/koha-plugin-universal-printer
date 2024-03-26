package Koha::Plugin::Fi::NatLib::UniversalPrinter::App::Crontab;
use Modern::Perl; use utf8; use open qw(:utf8);

## ----------------------------------------
## Plugin CRONTAB element
## ----------------------------------------

sub cronjob_nightly {
    my ( $self ) = @_;

    print "Remember to clean the kitchen\n";

    return;
}

1;
