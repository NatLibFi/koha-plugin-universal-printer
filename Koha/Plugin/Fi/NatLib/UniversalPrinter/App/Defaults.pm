package Koha::Plugin::Fi::NatLib::UniversalPrinter::App::Defaults;

use Modern::Perl; use utf8; use open qw(:utf8);

my $default_report_template = q{
    [% IF report_rows.size %]
    <table class="report-table">
        <thead>
            <tr>
                [% FOREACH header IN report_headers %]
                    <th>[% header %]</th>
                [% END %]
            </tr>
        </thead>
        <tbody>
            [% FOREACH row IN report_rows %]
                <tr>
                    [% FOREACH col IN row %]
                        <td>[% col %]</td>
                    [% END %]
                </tr>
            [% END %]
        </tbody>
    </table>
    [% ELSE %]
    <p>No data available to display.</p>
    [% END %]
};

my $default_report_style = q{
    .report-table {
        width: 50%;
        border-collapse: collapse;
        margin-bottom: 20px;
    }

    .report-table th, .report-table td {
        border: 1px solid #ddd;
        padding: 8px;
        text-align: left;
        font-size: 14px;
    }

    .report-table th {
        background-color: #f2f2f2;
        font-weight: bold;
    }

    .report-table tr:nth-child(even) {
        background-color: #f9f9f9;
    }
    .report-table tr:nth-child(odd) {
        background-color: #ffffff;
    }

    .report-table a {
        color: #1a0dab;
        text-decoration: none;
    }

    .report-table a:hover {
        text-decoration: underline;
    }
};

my $default_labels_template = q{
    [% FOREACH item IN items %]
        [% IF loop.index % 30 == 0 %]
            [% SET label_index = 1 %]
            [% UNLESS loop.first %]
                </span>
            [% END %]
            <span class="page">
        [% END %]

        <div class="label label[% label_index %]">
            [% item.biblio.title %]

            <br/>

            [% IF item.barcode %]
                <img src="/cgi-bin/koha/svc/barcode?barcode=[% item.barcode %]&type=Matrix2of5" />
            [% END %]

            <br/>

            [% item.itemnumber %]
        </div>
        [% IF loop.last %]</span>[% END %]
        [% SET label_index = label_index + 1 %]
    [% END %]
};

my $default_labels_style = q{
    html, body, div, span, h1 {
      margin: 0;
      padding: 0;
      border: 0;
    }

    body {
      width: 8.5in;
    }

    .page {
      padding-top: .5in; /* Height from top of page to top of first label row */
      margin-left: .25in; /* Width of gap from left of page to left edge of first label column */

      page-break-after: always;
      clear: left;
      display: block;
    }

    .label {
      width: 8.5in; /* Width of actual label */

      margin-right: 0in; /* Distance between each column of labels */

      float: left;
      text-align: center;
      overflow: hidden;

      outline: 1px dotted white;
    }

    .left-label {
      width: 1in;
      height: 1in;
      margin-right: .5in;


      float: left;
      text-align: center;
      overflow: hidden;

      background-color: red;
    }

    .center-label {
      width: 3in;
      height: 1in;
      margin-right: .5in;

      float: left;
      text-align: center;
      overflow: hidden;

      background-color: green;
    }

    .right-label {
      width: 3in;
      height: 1in;

      float: left;
      text-align: center;
      overflow: hidden;

      background-color: blue;
    }
};

my $default_holdsqueue_template = q{
    [% USE Branches %]
    [% FOREACH item IN queue_items %]

        <div class="a5-container">
            <div class="content">
                <div class="header">
                    <div class="item-info">
                        <div class="barcode-wrapper">
                            <div class="number">[% item.barcode FILTER upper %]</div>
                            <img src="/cgi-bin/koha/svc/barcode?barcode=[% item.barcode FILTER upper %]&type=Code39&notext=1" />
                        </div>
                    </div>
                    <div class="itemcallnumber">
                        [% IF item.itemcallnumber.length > 44 %]
                            <span class="number small-font">[% item.itemcallnumber %]</span>
                        [% ELSE %]
                            <span class="number normal-font">[% item.itemcallnumber %]</span>
                        [% END %]
                    </div>
                </div>
                <!-- <div class="main"> -->
                    <table class="content-table">
                        <tbody>
                            <tr><td class="t-label">PVM:</td>               <td class="t-data">[% item.reservedate%]</td></tr>
                            <tr><td class="t-label">Tek.:</td>              <td class="t-data">[% item.biblio.author %]</td></tr>
                            <tr><td class="t-label">Nim.:</td>              <td class="t-data">[% item.biblio.title %] [% item.biblio.subtitle %]</td></tr>

                            [% IF item.seriesarray.join('') %]
                                <tr><td class="t-label">Sarja:</td>             <td class="t-data">[% item.seriesarray.join('') %]</td></tr>
                            [% END %]

                            [% IF item.item.enumchron %]
                                <tr><td class="t-label">Osa.:</td>              <td class="t-data">[% item.item.enumchron %]</td></tr>
                            [% END %]

                            <tr><td class="t-label">Julk.:</td>             <td class="t-data">[% item.biblio.copyrightdate %]</td></tr>
                            <tr><td class="t-label">Kokoelma:</td>          <td class="t-data">[% item.item.ccode %]</td></tr>
                            <tr><td class="t-label">Nidetyyppi:</td>        <td class="t-data">[% item.item.itype %]</td></tr>

                            [% IF item.item.itemnotes %]
                                <tr><td class="t-label">Nidehuom.</td>          <td class="t-data">[% item.item.itemnotes %]</td></tr>
                            [% END %]

                            <tr><td class="t-label">Lähetä:</td>            <td class="t-data">[% Branches.GetName( item.pickbranch ) | html %] ([% item.pickbranch %])</td></tr>
                        </tbody>
                    </table>
                <!-- </div> -->
                <div class="footer">
                    <div class="notes">Huom: [% item.notes %]</div>
                <!-- <div class="borrower-info"> -->
                    <div class="borrower-info">
                        <div class="borrower">
                                <span><b>[% item.surname %], [% item.firstname %]</b></span>
                           <div class="b-id">
                                <span>[% item.patron.category.description %] ([% item.patron.categorycode %])</span>
                                <span class="number">&nbsp;[% item.cardnumber %]</span>
                           </div>
                        </div>
                        [% IF item.cardnumber.match('^\d+$') %]
                            <img src="/cgi-bin/koha/svc/barcode?barcode=[% item.cardnumber %]&type=Matrix2of5&notext=1" />
                        [% END %]
                    </div>
                <!-- </div> -->
                </div>
            </div>
        </div>
    [% END %]
};

my $default_holdsqueue_style = q{
    @import url('https://fonts.googleapis.com/css2?family=Roboto+Mono:ital,wght@0,100..700;1,100..700&family=Source+Serif+4:ital,opsz,wght@0,8..60,200..900;1,8..60,200..900&display=swap');

    * {
        box-sizing: border-box;
    }

    body {
        font-family: 'Source Serif 4', serif;
        font-size: 13pt;
        color: #000;
    }

    .a5-container {
        width: 200mm;
        height: 140mm;
        border-bottom: 0.3mm dashed #CECECE;
        margin-bottom: 10mm;
        overflow: hidden;
        display: inline-block;
        vertical-align: top;
        position: relative;
        padding: 0 6mm;
    }

    .header, .borrower-info {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin: 5mm 0 0;
    }

    .borrower-info {
        margin: 1mm;
    }

    .item-info, .borrower-info {
        display: flex;
        flex-direction: row;
        justify-content: center;
    }

    .barcode-wrapper {
        position: relative;
        display: inline-block;
        text-align: center;
        font-size: 21px;
    }

    .borrower {
        display: flex;
        flex-direction: column;
        align-items: end;
    }

    .itemcallnumber {
        margin-left: 30px;
    }

    .normal-font {
        font-size: 24pt;
    }

    .small-font {
        font-size: 16pt;
    }

    .desc-label {
        color: #939393;
    }

    .callslip {
        font-size: 18pt;
        color: #999;
        font-weight: bold;
        text-align: center;
    }

    .number {
        font-family: 'Roboto Mono', monospace;
        color: #000;
        font-weight: 800;
    }

    .content-table {
        border-collapse: collapse;
        width: 100%;
    }

    .content-table tr:nth-child(even) {
        background-color: #ebebeb;
    }

    .t-label {
        width: 23%;
        padding-right: 10px;
        text-align: left;
        padding-left: 7px;
        font-size: 14pt;
    }

    .t-data {
        word-wrap: break-word;
        font-size: 14pt;
        max-height: 2.8em;
        overflow: hidden;
        display: inline-block;
    }

    .footer {
        position: absolute;
        bottom: 10px;
        width: 94%;
    }

    .asiakas, .b-id {
        display: flex;
        flex-direction: row;
    }

    .notes {
        background-color: #CECECE;
        padding-left: 7px;
        font-size: 13pt;
    }

    img {
        padding-left: 7px;
    }

    @media print {
        .a5-container {
            margin-bottom: 6mm;
        }
        .a5-container:nth-of-type(2n) {
            page-break-after: auto;
        }
        .a5-container:nth-of-type(2n+1) {
            clear: both;
        }
    }
};

our $CONFIGURATION = [
    {   name => 'reports_template',
        type => 'textarea',
        default => $default_report_template,
        name_display => 'Reports Template',
        description => '...',
    },
    {   name => 'reports_style',
        type => 'textarea',
        default => $default_report_style,
        name_display => 'Reports Style',
        description => '...',
    },
    {   name => 'labelsbatches_template',
        type => 'textarea',
        default => $default_labels_template,
        name_display => 'Labels batches Template',
        description => '...',
    },
    {   name => 'labelsbatches_style',
        type => 'textarea',
        default => $default_labels_style,
        name_display => 'Labels batches Style',
        description => '...',
    },
    {   name => 'holdsqueue_template',
        type => 'textarea',
        default => $default_holdsqueue_template,
        name_display => 'Holds queue Template',
        description => '...',
    },
    {   name => 'holdsqueue_style',
        type => 'textarea',
        default => $default_holdsqueue_style,
        name_display => 'Holds queue Style',
        description => '...',
    },
];

1;
