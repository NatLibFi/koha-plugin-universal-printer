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
        } elsif ( $cgi->param('action') eq 'print_datatables' ) {
            my $template = $self->{config}{datatables_template};
            my $style    = $self->{config}{datatables_style};

            my $results_raw = $cgi->param('datatable_data');
            my $url_path = $cgi->param('url_path');

            my $results = JSON::decode_json($results_raw);

            $page_template->param(
                total                  => scalar @$results,
                table_rows             => $results,
                url_path               => $url_path,
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

    my $report_id   = $cgi->param('report_id');
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
    # if we have at least 1 parameter, and it's not filled, then don't execute but ask for parameters
    # if ($sql =~ /<</ && !@sql_params) {
    #     # split on ??. Each odd (2,4,6,...) entry should be a parameter to fill
    #     my @split = split /<<|>>/,$sql;
    #     my @tmpl_parameters;
    #     my @authval_errors;
    #     my %uniq_params;
    #     for(my $i=0;$i<($#split/2);$i++) {
    #         my ($text,$authorised_value_all) = split /\|/,$split[$i*2+1];
    #         $authorised_value_all //='';
    #         my $sep = $authorised_value_all ? "|" : "";
    #         if( defined $uniq_params{$text.$sep.$authorised_value_all} ){
    #             next;
    #         } else { $uniq_params{$text.$sep.$authorised_value_all} = "$i"; }
    #         my ($authorised_value, $all) = split /:/, $authorised_value_all;
    #         my $input;
    #         my $labelid;
    #         if ( not defined $authorised_value ) {
    #             # no authorised value input, provide a text box
    #             $input = "text";
    #         } elsif ( $authorised_value eq "date" ) {
    #             # require a date, provide a date picker
    #             $input = 'date';
    #         } elsif ( $authorised_value eq "list" ) {
    #             # require a list, provide a textarea
    #             $input = 'textarea';
    #         } else {
    #             # defined $authorised_value, and not 'date'
    #             my $dbh=C4::Context->dbh;
    #             my @authorised_values;
    #             my %authorised_lib;
    #             # builds list, depending on authorised value...
    #             if ( $authorised_value eq "branches" ) {
    #                 my $libraries = Koha::Libraries->search( {}, { order_by => ['branchname'] } );
    #                 while ( my $library = $libraries->next ) {
    #                     push @authorised_values, $library->branchcode;
    #                     $authorised_lib{$library->branchcode} = $library->branchname;
    #                 }
    #             }
    #             elsif ( $authorised_value eq "itemtypes" ) {
    #                 my $sth = $dbh->prepare("SELECT itemtype,description FROM itemtypes ORDER BY description");
    #                 $sth->execute;
    #                 while ( my ( $itemtype, $description ) = $sth->fetchrow_array ) {
    #                     push @authorised_values, $itemtype;
    #                     $authorised_lib{$itemtype} = $description;
    #                 }
    #             }
    #             elsif ( $authorised_value eq "biblio_framework" ) {
    #                 my @frameworks = Koha::BiblioFrameworks->search({}, { order_by => ['frameworktext'] })->as_list;
    #                 my $default_source = '';
    #                 push @authorised_values,$default_source;
    #                 $authorised_lib{$default_source} = 'Default';
    #                 foreach my $framework (@frameworks) {
    #                     push @authorised_values, $framework->frameworkcode;
    #                     $authorised_lib{$framework->frameworkcode} = $framework->frameworktext;
    #                 }
    #             }
    #             elsif ( $authorised_value eq "cn_source" ) {
    #                 my $class_sources = GetClassSources();
    #                 my $default_source = C4::Context->preference("DefaultClassificationSource");
    #                 foreach my $class_source (sort keys %$class_sources) {
    #                     next unless $class_sources->{$class_source}->{'used'} or
    #                                 ($class_source eq $default_source);
    #                     push @authorised_values, $class_source;
    #                     $authorised_lib{$class_source} = $class_sources->{$class_source}->{'description'};
    #                 }
    #             }
    #             elsif ( $authorised_value eq "categorycode" ) {
    #                 my @patron_categories = Koha::Patron::Categories->search({}, { order_by => ['description']})->as_list;
    #                 %authorised_lib = map { $_->categorycode => $_->description } @patron_categories;
    #                 push @authorised_values, $_->categorycode for @patron_categories;
    #             }
    #             elsif ( $authorised_value eq "cash_registers" ) {
    #                 my $sth = $dbh->prepare("SELECT id, name FROM cash_registers ORDER BY description");
    #                 $sth->execute;
    #                 while ( my ( $id, $name ) = $sth->fetchrow_array ) {
    #                     push @authorised_values, $id;
    #                     $authorised_lib{$id} = $name;
    #                 }
    #             }
    #             elsif ( $authorised_value eq "debit_types" ) {
    #                 my $sth = $dbh->prepare("SELECT code, description FROM account_debit_types ORDER BY code");
    #                 $sth->execute;
    #                 while ( my ( $code, $description ) = $sth->fetchrow_array ) {
    #                    push @authorised_values, $code;
    #                    $authorised_lib{$code} = $description;
    #                 }
    #             }
    #             elsif ( $authorised_value eq "credit_types" ) {
    #                 my $sth = $dbh->prepare("SELECT code, description FROM account_credit_types ORDER BY code");
    #                 $sth->execute;
    #                 while ( my ( $code, $description ) = $sth->fetchrow_array ) {
    #                    push @authorised_values, $code;
    #                    $authorised_lib{$code} = $description;
    #                 }
    #             }
    #             else {
    #                 if ( Koha::AuthorisedValues->search({ category => $authorised_value })->count ) {
    #                     my $query = '
    #                     SELECT authorised_value,lib
    #                     FROM authorised_values
    #                     WHERE category=?
    #                     ORDER BY lib
    #                     ';
    #                     my $authorised_values_sth = $dbh->prepare($query);
    #                     $authorised_values_sth->execute( $authorised_value);

    #                     while ( my ( $value, $lib ) = $authorised_values_sth->fetchrow_array ) {
    #                         push @authorised_values, $value;
    #                         $authorised_lib{$value} = $lib;
    #                         # For item location, we show the code and the libelle
    #                         $authorised_lib{$value} = $lib;
    #                     }
    #                 } else {
    #                     # not exists $authorised_value_categories{$authorised_value})
    #                     push @authval_errors, {'entry' => $text,
    #                                            'auth_val' => $authorised_value };
    #                     # tell the template there's an error
    #                     $template->param( auth_val_error => 1 );
    #                     # skip scrolling list creation and params push
    #                     next;
    #                 }
    #             }
    #             $labelid = $text;
    #             $labelid =~ s/\W//g;
    #             $input = {
    #                 name    => "sql_params",
    #                 id      => "sql_params_".$labelid,
    #                 values  => \@authorised_values,
    #                 labels  => \%authorised_lib,
    #             };
    #         }

    #         push @tmpl_parameters, {'entry' => $text, 'input' => $input, 'labelid' => $labelid, 'name' => $text.$sep.$authorised_value_all, 'include_all' => $all };
    #     }
    #     $template->param('sql'         => $sql,
    #                     'name'         => $name,
    #                     'notes'         => $notes,
    #                     'sql_params'   => \@tmpl_parameters,
    #                     'auth_val_errors'  => \@authval_errors,
    #                     'enter_params' => 1,
    #                     'reports'      => $report_id,
    #                     );
    # } else {
        my ($sql_after,$header_types) = $report->prep_report( \@param_names, \@sql_params );
        # $template->param(header_types => $header_types);
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
            # $total = C4::Reports::Guided::nb_rows($sql) || 0;
            # my $headers = header_cell_loop($sth);
            # $template->param(header_row => $headers);
            while (my $row = $sth->fetchrow_arrayref()) {
                push @rows, [ @$row ];
            }

        }

    # }

    use Data::Dumper (); warn Data::Dumper->new( [{
        rows => \@rows,
    }],[ __PACKAGE__ . ":" . __LINE__ ])->Sortkeys(sub{return [sort { lc $a cmp lc $b } keys %{ $_[0] }];})->Maxdepth(4)->Indent(1)->Purity(0)->Deepcopy(1)->Dump. "\n";

    return \@rows;
}

1;
