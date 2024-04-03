<form method="get">
    <input type="hidden" name="class" value="[% CLASS %]"/>
    <input type="hidden" name="method" value="[% METHOD %]"/>

    <input type="hidden" name="action" value="print_labels" />

    <fieldset class="rows">
        <legend>Print labels</legend>
        <ol>
            <li>
                <label for="batch_id">Batch: </label>
                <select id="batch_id" name="batch_id">
                    [% logged_in_branchcode = Branches.GetLoggedInBranchcode() %]
                    [% FOREACH b IN batches %]
                        [% IF CAN_user_superlibrarian || CAN_user_loggedinlibrary || b.branch_code == logged_in_branchcode %]
                            <!-- TODO: ask from librarians do they need all the batches if they can see them (above) -->
                            <option class="[% b.branch_code | html %]" value="[% b.batch_id %]">[% b.branch_code | html%]: Batch #[% b.batch_id %] ([% b.items_count %]) [% b.description %]</option>
                        [% END %]
                    [% END %]
                </select>
            </li>
            <li>
                <label for="starting_label">Starting label: </label>
                <input type="number" min="1" step="1" id="starting_label" name="starting_label" value="1">
            </li>
        </ol>
    </fieldset>

    <fieldset class="action">
        <button type="submit" class="btn btn-primary">
            <i class="fa fa-print"></i> Print labels batch
        </button>
        <a href="?class=[% CLASS %]&method=[% METHOD %]">Cancel</a>
    </fieldset>
</form>
