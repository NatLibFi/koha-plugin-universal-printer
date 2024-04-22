<form method="get">
    <input type="hidden" name="class" value="[% CLASS %]"/>
    <input type="hidden" name="method" value="[% METHOD %]"/>

    <input type="hidden" name="action" value="print_reports" />

    <fieldset class="rows">
        <legend><a href="/cgi-bin/koha/reports/reports-home.pl">Go to reports section</a></legend>
        <span>To print an SQL query using this plugin, navigate to the query page. <br>
        After executing the desired query, a <b>[Universal Printer]</b> button will appear, allowing you to print the results of the query directly.</span>
    </fieldset>

    <!-- <fieldset class="action">
        <button type="submit" class="btn btn-primary">
            <i class="fa fa-print"></i> Print report
        </button>
    </fieldset> -->
</form>
