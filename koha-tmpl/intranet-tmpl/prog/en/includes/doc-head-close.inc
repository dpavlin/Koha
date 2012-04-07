<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
[% USE combine = Combine %]
<link rel="shortcut icon" href="[% IF ( IntranetFavicon ) %][% IntranetFavicon %][% ELSE %][% themelang %]/includes/favicon.ico[% END %]" type="image/x-icon" />
[% combine.css( href => themelang _ "/lib/jquery/plugins/ui.tabs.css" ) %]
[% combine.css( media => "print" href => themelang _ "/css/print.css" ) %]
[% IF ( intranetstylesheet ) %]
    [% combine.css( href => intranetstylesheet ) %]
[% ELSE %]
    [% combine.css( href => themelang _ "/css/staff-global.css" ) %]
[% END %]
[% IF ( IntranetUserCSS ) %]<style type="text/css">[% IntranetUserCSS %]</style>[% END %]
[% combine.javascript( src => themelang _ "/lib/jquery/jquery.js" ) %]
[% combine.javascript( src => themelang _ "/lib/jquery/plugins/ui.tabs.js" ) %]
[% combine.javascript( src => themelang _ "/lib/jquery/plugins/jquery.hotkeys.min.js" ) %]
[% combine.javascript( src => themelang _ "/lib/jquery/plugins/jquery.cookie.min.js" ) %]
[% combine.javascript( src => themelang _ "/lib/jquery/plugins/jquery.highlight-3.js" ) %]
[% IF ( login ) %]
    [% combine.css( href => themelang _ "/css/login.css" ) %]
[% END %]
[% IF ( wizard ) %]
    [% combine.css( href => themelang _ "/css/wizard.css" ) %]
[% END %]

<!-- local colors -->
[% IF ( intranetcolorstylesheet ) %]
    [% combine.css( href => themelang _ "/css/" _ intranetcolorstylesheet ) %]
[% END %]

<!-- yui js --> 
[% combine.javascript( src => yuipath _ "/utilities/utilities.js" ) %] 
[% combine.javascript( src => yuipath _ "/datasource/datasource-min.js" ) %]
[% IF ( CircAutocompl ) %]
    [% combine.javascript( src => yuipath _ "/autocomplete/autocomplete-min.js" ) %]
[% END %]
[% combine.javascript( src => yuipath _ "/button/button-min.js" ) %] 
[% combine.javascript( src => yuipath _ "/container/container_core-min.js" ) %] 
[% combine.javascript( src => yuipath _ "/menu/menu-min.js" ) %] 

<!-- koha core js -->
[% combine.javascript( src => themelang _ "/js/staff-global.js" ) %]
[% IF ( intranetuserjs ) %]
    <script type="text/javascript">
    //<![CDATA[
    [% intranetuserjs %]
    //]]>
    </script>
[% END %]
<script type="text/javascript" language="javascript">
    //<![CDATA[
    [% IF ( intranetbookbag ) %]var MSG_BASKET_EMPTY = _("Your cart is currently empty");
        var MSG_RECORD_IN_BASKET = _("This item is already in your cart");
        var MSG_RECORD_ADDED = _("This item has been added to your cart");
        var MSG_NRECORDS_ADDED = _(" item(s) added to your cart");
        var MSG_NRECORDS_IN_BASKET = _("already in your cart");
        var MSG_NO_RECORD_SELECTED = _("No item was selected");
        var MSG_NO_RECORD_ADDED = _("No item was added to your cart");
        var MSG_CONFIRM_DEL_BASKET = _("Are you sure you want to empty your cart?");
        var MSG_CONFIRM_DEL_RECORDS = _("Are you sure you want to remove the selected items?");
        var MSG_NON_RESERVES_SELECTED = _("One or more selected items cannot be reserved.");
    [% END %]
    //]]>
    </script>
    [% IF ( virtualshelves || intranetbookbag ) %]
        [% combine.javascript( src => themelang _ "/js/basket.js" ) %]
    [% END %]
[% IF LocalCoverImages %]
[% combine.javascript( src => themelang _ "/js/localcovers.js" ) %]
<script type="text/javascript" language="javascript">
//<![CDATA[
var NO_LOCAL_JACKET = _("No cover image available");
//]]>
</script>
[% END %]
[% combine.html %]
