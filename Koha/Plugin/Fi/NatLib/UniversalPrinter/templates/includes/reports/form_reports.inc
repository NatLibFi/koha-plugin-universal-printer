<form method="get">
    <input type="hidden" name="class" value="[% CLASS %]"/>
    <input type="hidden" name="method" value="[% METHOD %]"/>

    <input type="hidden" name="action" value="print_report" />

    <fieldset class="rows">
        <legend>Select holds queue</legend>
        <ol>
            <li>
                <label for="branchlimit">Library: </label>
                <select name="branchlimit" id="branchlimit">
                    [% IF CAN_user_superlibrarian || !Koha.Preference('IndependentBranches') %]
                        <option value="">All</option>
                    [% END %]
                    [% PROCESS options_for_libraries libraries => Branches.all( selected => branchlimit, only_from_group => 1 ) %]
                </select>
            </li>
            <li>
                <label for="itemtypeslimit">Item type: </label>
                <select name="itemtypeslimit" id="itemtypeslimit">
                    <option value="">All</option>
                    [% PROCESS options_for_item_types itemtypes => ItemTypes.Get(), selected_itemtype => itemtypeslimit %]
                </select>
            </li>
            <li>
                <label for="ccodeslimit">Collection: </label>
                <select name="ccodeslimit" id="ccodeslimit">
                    <option value="">All</option>
                    [% PROCESS options_for_authorised_values authorised_values => AuthorisedValues.GetAuthValueDropbox( 'CCODE' ), selected_av => ccodeslimit %]
                </select>
            </li>
            <li>
                <label for="locationslimit">Shelving location: </label>
                <select name="locationslimit" id="locationslimit">
                    <option value="">All</option>
                    [% PROCESS options_for_authorised_values authorised_values => AuthorisedValues.GetAuthValueDropbox( 'LOC' ), selected_av => locationslimit %]
                </select>
            </li>
        </ol>
    </fieldset>

    <fieldset class="action">
        <button type="submit" class="btn btn-primary">
            <i class="fa fa-print"></i> Print slips
        </button>
        <a href="?class=[% CLASS %]&method=[% METHOD %]">Cancel</a>
    </fieldset>
</form>
