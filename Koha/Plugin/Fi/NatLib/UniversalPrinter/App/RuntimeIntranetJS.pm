package Koha::Plugin::Fi::NatLib::UniversalPrinter::App::RuntimeIntranetJS;
use Modern::Perl; use utf8; use open qw(:utf8);


## ----------------------------------------
## Plugin runtime Intranet JS
## ----------------------------------------

sub runtime_intranet_js {
    my ( $self ) = @_;

    return q|<script>

        function attach_self_to_reporttable() {
            var reportTable = $('#sql_output'); // Find the element with ID 'sql_output'
            var button = $('<button>').text('Send to Universal Printer plugin');

            button.on('click', function() {
                var report_number = $('.report_number').text(); // Get report number from the text
                var form = $('<form>').attr({
                    method: 'POST',
                    action: '/cgi-bin/koha/plugins/run.pl'
                }).css({
                    display: 'none'
                });

                console.log('report_number', report_number);

                // Add hidden inputs to the form
                $('<input>').attr({ type: 'hidden', name: 'class', value: '|.$self->{plugin}{metadata}{class}.q|' }).appendTo(form);
                $('<input>').attr({ type: 'hidden', name: 'method', value: 'report' }).appendTo(form);
                $('<input>').attr({ type: 'hidden', name: 'action', value: 'print_reports' }).appendTo(form);
                $('<input>').attr({ type: 'hidden', name: 'report_id', value: report_number }).appendTo(form); // Add report's number as 'report_id'

                $('body').append(form);
                form.submit();
            });

            reportTable.before(button);
        }


        $(function() {
            attach_self_to_reporttable();
        });
    </script>|;
}

1;
