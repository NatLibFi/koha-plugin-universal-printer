package Koha::Plugin::Fi::NatLib::UniversalPrinter::App::RuntimeReport;
use Modern::Perl; use utf8; use open qw(:utf8);

use C4::Auth;
use C4::Context;

use Koha::Libraries;
use Koha::Patron::Categories;

use Koha::DateUtils qw( dt_from_string );


## ----------------------------------------
## Plugin runtime REPORT phase
## ----------------------------------------

sub runtime_report_mode {
    my ( $self, $args ) = @_;
    my $cgi = $self->{plugin}{cgi};

    $self->go_home();

    return;
}

1;
