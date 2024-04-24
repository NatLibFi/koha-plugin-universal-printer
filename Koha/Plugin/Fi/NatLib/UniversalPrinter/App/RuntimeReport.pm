package Koha::Plugin::Fi::NatLib::UniversalPrinter::App::RuntimeReport;
use Modern::Perl; use utf8; use open qw(:utf8);

use C4::Auth;
use C4::Context;

use C4::HoldsQueue qw( GetHoldsQueueItems );
use Koha::Items;

use Koha::DateUtils qw( dt_from_string );

use Koha::Reports;
use C4::Reports::Guided;

use JSON;


## ----------------------------------------
## Plugin runtime REPORT phase
## ----------------------------------------

sub runtime_report_mode {
    my ( $self, $args ) = @_;
    my $cgi = $self->{plugin}{cgi};

    my $page_template;

    if ( $cgi->param('action') ) {

        $page_template = $self->get_template( { file => 'templates/reports/print_results.tt' } );

        if ( $cgi->param('action') eq 'print_reports' ) {
            my $template = $self->{config}{reports_template};
            my $style    = $self->{config}{reports_style};

            unless (C4::Auth::haspermission(C4::Context->userenv->{id},{ reports =>'execute_reports' })) {
                die;
            }

            my $results = execute_report($cgi);

            $page_template->param(
                total                  => scalar @$results,
                report_rows            => $results,
                report_template        => $template,
                report_style           => $style,
            );
        } elsif ( $cgi->param('action') eq 'print_labels' ) {
            my $template = $self->{config}{labelsbatches_template};
            my $style    = $self->{config}{labelsbatches_style};

            my $batch_id       = $cgi->param('batch_id');
            my $starting_label = $cgi->param('starting_label');

            my @results;

            my $dbh = C4::Context->dbh;
            my $batch = $dbh->selectall_arrayref(
                'SELECT * FROM creator_batches WHERE batch_id = ?',
                { Slice => {} }, $batch_id );

            push( @results, undef ) for ( 1 .. $starting_label - 1 );

            foreach my $b (@$batch) {
                my $item = Koha::Items->find( $b->{item_number} );
                push( @results, $item );
            }

            $page_template->param(
                total                  => scalar @results,
                items                  => \@results,
                report_template        => $template,
                report_style           => $style,
            );
        } elsif ( $cgi->param('action') eq 'print_holdsqueue' ) {
            my $template = $self->{config}{holdsqueue_template};
            my $style    = $self->{config}{holdsqueue_style};

            my $branchlimit     = $cgi->param('branchlimit');
            my $itemtypeslimit  = $cgi->param('itemtypeslimit');
            my $ccodeslimit     = $cgi->param('ccodeslimit');
            my $locationslimit  = $cgi->param('locationslimit');

            my $results = GetHoldsQueueItems(
                {
                    branchlimit    => $branchlimit,
                    itemtypeslimit => $itemtypeslimit,
                    ccodeslimit    => $ccodeslimit,
                    locationslimit => $locationslimit
                }
            );

            $page_template->param(
                total                  => $results->count,
                queue_items            => $results->as_list // [],
                report_template        => $template,
                report_style           => $style,
            );
        }
    }
    else {
        $page_template = $self->get_template( { file => 'templates/reports/choose_what_to_print_form.tt' } );

        my $dbh = C4::Context->dbh;
        my $batches = $dbh->selectall_arrayref(
           'SELECT batch_id, COUNT(batch_id) AS items_count, description, branch_code FROM creator_batches WHERE creator = "Labels" GROUP BY batch_id ORDER BY timestamp DESC', { Slice => {} } );
        my $reports = Koha::Reports->search();

        $page_template->param(
            batches => $batches,
            reports => $reports,
        );
    }

    $self->output_html( $page_template->output() );

    return;
}

sub execute_report {
    my $cgi = shift;

    my $report_id   = $cgi->param('reports');
    my @sql_params  = $cgi->multi_param('sql_params');
    my @param_names = $cgi->multi_param('param_name');
    my $limit       = $cgi->param('limit');
    my $offset      = 0;

    my $report = Koha::Reports->find($report_id);

    die "Report not found: $report_id"
        unless $report;

    my ( $sql, $original_sql, $type, $name, $notes );

    $sql   = $original_sql = $report->savedsql;
    $name  = $report->report_name;
    $notes = $report->notes;

    my @rows = ();
    my ($sql_after,$header_types) = $report->prep_report( \@param_names, \@sql_params );
    my ( $sth, $errors ) = C4::Reports::Guided::execute_query(
        {
            sql        => $sql_after,
            offset     => $offset,
            limit      => $limit,
            report_id  => $report_id,
        }
    );
    my $total;
    if (!$sth) {
        die "execute_query failed to return sth for report $report_id: $sql";
    } elsif ( !$errors ) {
        while (my $row = $sth->fetchrow_arrayref()) {
            push @rows, [ @$row ];
        }
    }

    return \@rows;
}

1;
