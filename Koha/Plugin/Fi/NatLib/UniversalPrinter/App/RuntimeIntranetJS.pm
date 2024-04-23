package Koha::Plugin::Fi::NatLib::UniversalPrinter::App::RuntimeIntranetJS;
use Modern::Perl; use utf8; use open qw(:utf8);


## ----------------------------------------
## Plugin runtime Intranet JS
## ----------------------------------------

sub runtime_intranet_js {
    my ( $self ) = @_;

    return q|<script>

        function attach_self_to_reporttable() {
            var report_table = $('#sql_output'); // Find the element with ID 'sql_output'
            var button = $('<button>').text('Send to Universal Printer plugin');

            button.on('click', function() {
                var url_params = new URLSearchParams(window.location.search);
                var form = $('<form>').attr({
                    method: 'POST',
                    action: '/cgi-bin/koha/plugins/run.pl'
                }).css({
                    display: 'none'
                });

                // Add required fields inputs to the form
                $('<input>').attr({ type: 'hidden', name: 'class', value: '|.$self->{plugin}{metadata}{class}.q|' }).appendTo(form);
                $('<input>').attr({ type: 'hidden', name: 'method', value: 'report' }).appendTo(form);
                $('<input>').attr({ type: 'hidden', name: 'action', value: 'print_reports' }).appendTo(form);

                // Select allowed URL parameters and add them as hidden fields to the form
                const allowed_params = ['reports', 'param_name', 'sql_params'];
                url_params.forEach(function(value, key) {
                    if (allowed_params.includes(key)) {
                        $('<input>').attr({
                            type: 'hidden',
                            name: key,
                            value: value
                        }).appendTo(form);
                    }
                });

                $('body').append(form);
                form.submit();
            });

            report_table.before(button);
        }


        $(function() {
            attach_self_to_reporttable();
        });
    </script>|;
}

1;
