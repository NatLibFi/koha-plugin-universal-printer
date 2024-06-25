package Koha::Plugin::Fi::NatLib::UniversalPrinter::App::RuntimeIntranetJS;
use Modern::Perl; use utf8; use open qw(:utf8);


## ----------------------------------------
## Plugin runtime Intranet JS
## ----------------------------------------

sub runtime_intranet_js {
    my ( $self ) = @_;

    return q!<script>

            function attachSelfToReporttable(reportTableId) {
                var reportTable = $('#' + reportTableId); // Use the passed ID to select the element
                var button = $('<button>').text('Send to Universal Printer plugin').css({
                        padding: '5px',
                        margin: '0 0 5px 0'
                    });

                button.on('click', function() {
                    const urlParams = new URLSearchParams(window.location.search);
                    var form = $('<form>').attr({
                        method: 'POST',
                        action: '/cgi-bin/koha/plugins/run.pl'
                    }).css({
                        display: 'none'
                    });

                    // Determine the action for the form
                    var actionValue = reportTableId === 'toolbar' ? 'print_reports' : 'print_holdsqueue';

                    // Add additional parameters for holdst_wrapper from URL, if needed
                    $('<input>').attr({ type: 'hidden', name: 'class', value: '!.$self->{plugin}{metadata}{class}.q!' }).appendTo(form);
                    $('<input>').attr({ type: 'hidden', name: 'csrf_token', value: '!.$self->GenerateCSRF().q!' }).appendTo(form);
                    $('<input>').attr({ type: 'hidden', name: 'method', value: 'report' }).appendTo(form);
                    $('<input>').attr({ type: 'hidden', name: 'action', value: actionValue }).appendTo(form);

                    // Add additional parameters for holdst_wrapper from URL, if needed
                    if (reportTableId === 'holdst_wrapper') {
                        ['branchlimit', 'itemtypeslimit', 'ccodeslimit', 'locationslimit'].forEach(function(param) {
                            $('<input>').attr({ type: 'hidden', name: param, value: urlParams.get(param) }).appendTo(form);
                        });
                    }

                    // Add allowed URL parameters to the form
                    const allowed_params = ['reports', 'param_name', 'sql_params'];
                    urlParams.forEach(function(value, key) {
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

                if (reportTableId === 'holdst_wrapper') {
                    reportTable.find('.dt-buttons').append(button); // Add button to dt-buttons div
                } else if (reportTableId === 'toolbar') {
                    $('#toolbar').append(button); // Add button to the toolbar div
                }
        }

        $(function() {
            // Determine the page and element ID based on the URL
            var path = window.location.pathname;
            var urlParams = new URLSearchParams(window.location.search);
            var phase = urlParams.get('phase'); // Koha <= 23.11
            var op = urlParams.get('op');       // Koha >= 24.05
            var targetId = path.includes('view_holdsqueue.pl') ? 'holdst_wrapper' :
                           (path.includes('guided_reports.pl') && (phase === 'Run this report' || op === 'run')) ? 'toolbar' : undefined;

            if (targetId) {
                attachSelfToReporttable(targetId);
            }
        });

        $(function() {
            attachSelfToReporttable();
        });

    </script>!;
}

1;
