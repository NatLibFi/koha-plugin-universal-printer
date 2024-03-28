package Koha::Plugin::Fi::NatLib::UniversalPrinter::App::RuntimeReport;
use Modern::Perl; use utf8; use open qw(:utf8);

use C4::Auth;
use C4::Context;

use C4::HoldsQueue qw( GetHoldsQueueItems );
use Koha::Items;

use Koha::DateUtils qw( dt_from_string );



## ----------------------------------------
## Plugin runtime REPORT phase
## ----------------------------------------

sub runtime_report_mode {
    my ( $self, $args ) = @_;
    my $cgi = $self->{plugin}{cgi};

    if ( $cgi->param('action') && $cgi->param('action') eq 'print_report' ) {

        my $template = $self->{config}{template};
        my $style    = $self->{config}{style};

        my $branchlimit     = $cgi->param('branchlimit');
        my $itemtypeslimit  = $cgi->param('itemtypeslimit');
        my $ccodeslimit     = $cgi->param('ccodeslimit');
        my $locationslimit  = $cgi->param('locationslimit');

        # my $items = Koha::Items->search({ itemnumber => 273 });

        my $items = GetHoldsQueueItems(
            {
                branchlimit    => $branchlimit,
                itemtypeslimit => $itemtypeslimit,
                ccodeslimit    => $ccodeslimit,
                locationslimit => $locationslimit
            }
        );

        $self->report_print(
            {
                total           => $items->count,
                items           => $items->as_list // [],
                template        => $template,
                style           => $style,
            }
        );
    }
    else {
        $self->report_data_form();
    }

    return;
}

sub report_print {
    my ( $self, $args ) = @_;

    my $total              = $args->{total};
    my $items              = $args->{items};
    my $template           = $args->{template};
    my $style              = $args->{style};

    my $page_template = $self->get_template( { file => 'templates/print_report.tt' } );

    # use Data::Dumper (); warn Data::Dumper->new( [{
    #      items => $items,
    #  }],[ __PACKAGE__ . ":" . __LINE__ ])->Sortkeys(sub{return [sort { lc $a cmp lc $b } keys %{ $_[0] }];})->Maxdepth(12)->Indent(1)->Purity(0)->Deepcopy(1)->Dump. "\n";

    $page_template->param(
        total                  => $total,
        items                  => $items,
        report_template        => $template,
        report_style           => $style,
    );

    $self->output_html( $page_template->output() );

    return;
}

sub report_data_form {
    my ( $self, $args ) = @_;

    my $template = $self->get_template( { file => 'templates/print_report_form.tt' } );

    $self->output_html( $template->output() );
}


1;
