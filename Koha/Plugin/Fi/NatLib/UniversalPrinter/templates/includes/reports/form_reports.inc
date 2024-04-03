<form method="get">
    <input type="hidden" name="class" value="[% CLASS %]"/>
    <input type="hidden" name="method" value="[% METHOD %]"/>

    <input type="hidden" name="action" value="print_reports" />

    <fieldset class="rows">
        <legend>Select report</legend>
        <ol>
            <li>
                <label for="report_id">Report: </label>
                <select name="report_id" id="report_id">
                    [% FOR report IN reports %]
                        <option value="[% report.id %]">[% report.id %] - [% report.report_name %]</option>
                    [% END %]
                </select>
            </li>
        </ol>
    </fieldset>

    <fieldset class="action">
        <button type="submit" class="btn btn-primary">
            <i class="fa fa-print"></i> Print report
        </button>
        <a href="?class=[% CLASS %]&method=[% METHOD %]">Cancel</a>
    </fieldset>
</form>
