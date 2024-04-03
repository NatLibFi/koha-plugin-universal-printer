package Koha::Plugin::Fi::NatLib::UniversalPrinter::App::RuntimeIntranetJS;
use Modern::Perl; use utf8; use open qw(:utf8);


## ----------------------------------------
## Plugin runtime Intranet JS
## ----------------------------------------

sub runtime_intranet_js {
    my ( $self ) = @_;

    return q|<script>

        function attach_self_to_datatables() {
            let tables = $.fn.dataTable.tables();
            // console.log(tables);
            $.each(tables, function(index, value) {
                console.log(index, value);
                let datatable = $(value).DataTable();
                // console.log(datatable);
                datatable.button().add(0, {
                    action: function (e, dt, button, config) {
                        let data = datatable.rows().data();
                        // console.log(data);
                        var form = $('<form>').attr({
                            method: 'POST',
                            action: '/cgi-bin/koha/plugins/run.pl'
                        }).css({
                            display: 'none'
                        });
                        var jsonData = JSON.stringify(data.toArray());
                        $('<input>').attr({ type: 'hidden', name: 'datatable_data', value: jsonData }).appendTo(form);
                        $('<input>').attr({ type: 'hidden', name: 'class', value: '|.$self->{plugin}{metadata}{class}.q|' }).appendTo(form);
                        $('<input>').attr({ type: 'hidden', name: 'method', value: 'report' }).appendTo(form);
                        $('<input>').attr({ type: 'hidden', name: 'action', value: 'print_datatables' }).appendTo(form);
                        $('<input>').attr({ type: 'hidden', name: 'url_path', value: window.location.pathname }).appendTo(form);

                        $('body').append(form);
                        form.submit();
                    },
                    text: 'send table page to Universal Printer',
                });
            });
        }

        $(function() {
            if (window.location.pathname == '/cgi-bin/koha/members/members-home.pl') {
                alert('I should wait for datatables export button to appear in the future');
            } else if (window.location.pathname == '/cgi-bin/koha/circ/circulation.pl') {
                alert('I should wait for datatables export button to appear in the future');
                // wait for DOM changes for datatables to appear:
                // var observer = new MutationObserver(function(mutations) {
                //     mutations.forEach(function(mutation) {
                //         if (mutation.addedNodes.length) {
                //             attach_self_to_datatables();
                //         }
                //     });
                // });
                // observer.observe(document.body, {
                //     childList: true,
                //     subtree: true,
                // });
            } else{
                attach_self_to_datatables();
            }
        });
    </script>|;
}

1;
