[% IF ( patron.address or patron.address2 ) %]
    [% IF ( patron.address ) %]
        [% SET roadtype_desc = '' %]
        [% IF patron.streettype %]
            [% SET roadtype_desc = AuthorisedValues.GetByCode('ROADTYPE', patron.streettype) %]
        [% END %]
        <li class="patronaddress1">[% if (patron.streetnumber) | html %][% patron.streetnumber |html  %][% end | html %] [% patron.address | html %] [% IF roadtype_desc %][% roadtype_desc |html  %] [% END %][% end | html %]</li>
    [% END %]
    [% IF ( patron.address2 ) %]
        <li class="patronaddress2">[% patron.address2 |html  %]</li>
    [% END %]
[% END %]
[% IF ( patron.city ) %]<li class="patroncity">
        [% patron.city |html  %][% IF ( patron.state ) %], [% patron.state |html  %][% END %]
        [% patron.zipcode |html  %][% IF ( patron.country ) %], [% patron.country |html  %][% END %]</li>
[% END %]
