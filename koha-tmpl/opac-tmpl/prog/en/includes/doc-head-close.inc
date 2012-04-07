</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta name="generator" content="Koha [% Version %]" /> <!-- leave this for stats -->
<link rel="shortcut icon" href="[% IF ( OpacFavicon ) %][% OpacFavicon %][% ELSE %][% themelang %]/includes/favicon.ico[% END %]" type="image/x-icon" />
[% USE combine = Combine %]
[% IF ( opacstylesheet ) %]
    [% combine.css( href => opacstylesheet ) %]
[% ELSE %]
    [% IF ( opaclayoutstylesheet ) %]
        [% combine.css( href => themelang _ "/css/" _ opaclayoutstylesheet ) %]
    [% ELSE %]
        [% combine.css( href => themelang _ "/css/opac.css" ) %]
    [% END %]
[% END %]
[% IF ( opaccolorstylesheet ) %]
    [% combine.css( href => themelang _ "/css/" _ opaccolorstylesheet ) %]
[% END %]
[% IF ( opacexternalsheet ) %]
    [% combine.css( href => opacexternalsheet ) %]
[% END %]
[% IF ( opac_css_override ) %]
    [% combine.css( href => therelang _ "/css/" _ opac_css_override ) %]
[% END %]
<link rel="stylesheet" type="text/css" media="print" href="[% themelang %]/css/print.css" />
[% combine.css( href => themelang _ "/lib/jquery/plugins/ui.tabs.css" ) %]
[% IF ( OPACUserCSS ) %]<style type="text/css">[% OPACUserCSS %]</style>[% END %]
<!-- yui js --> 
[% combine.css( href => yuipath _ "/reset-fonts-grids.css" ) %]
[% combine.css( href => yuipath _ "/skin.css" ) %]
[% combine.javascript( src => yuipath  _ "/utilities/utilities.js" ) %] 
[% combine.javascript( src => yuipath  _ "/container/container-min.js" ) %] 
[% combine.javascript( src => yuipath  _ "/menu/menu-min.js" ) %] 
[% combine.javascript( src => themelang  _ "/lib/jquery/jquery.js" ) %]
[% combine.javascript( src => themelang  _ "/lib/jquery/plugins/ui.tabs.js" ) %]
[% combine.javascript( src => themelang  _ "/lib/jquery/plugins/jquery.hoverIntent.minified.js" ) %]
[% combine.javascript( src => themelang _ "/js/script.js" ) %]

[% IF ( OPACAmazonCoverImages ) %]
[% combine.javascript( cdata => "var NO_AMAZON_IMAGE = _(\"No cover image available\");" ) %]
[% combine.javascript( src => themelang _ "/js/amazonimages.js" ) %]
[% END %]
[% IF ( SyndeticsCoverImages ) %]
[% combine.javascript( cdata => "var NO_AMAZON_IMAGE = _(\"No cover image available\");" ) %]
[% combine.javascript( src => themelang _ "/js/amazonimages.js" ) %]
[% END %]

[% IF ( opacbookbag ) %]
  [% combine.javascript( src => themelang _ "/js/basket.js" ) %]
[% ELSIF ( virtualshelves ) %]
  [% combine.javascript( src => themelang _ "/js/basket.js" ) %]
[% ELSE %]
  [% combine.javascript( cdata => "var readCookie;" ) %]
[% END %]

[% combine.javascript( cdata => "var cdata_test;" ) %]
<script type="text/javascript" language="javascript">
	//<![CDATA[
function _(s) { return s } // dummy function for gettext
[% IF ( opacbookbag ) %]
    var MSG_BASKET_EMPTY = _("Your cart is currently empty");
    var MSG_RECORD_IN_BASKET = _("This item is already in your cart");
    var MSG_RECORD_ADDED = _("This item has been added to your cart");
    var MSG_RECORD_REMOVED = _("This item has been removed from your cart");
    var MSG_NRECORDS_ADDED = _(" item(s) added to your cart");
    var MSG_NRECORDS_IN_BASKET = _("already in your cart");
    var MSG_NO_RECORD_SELECTED = _("No item was selected");
    var MSG_NO_RECORD_ADDED = _("No item was added to your cart");
    var MSG_CONFIRM_DEL_BASKET = _("Are you sure you want to empty your cart?");
    var MSG_CONFIRM_DEL_RECORDS = _("Are you sure you want to remove the selected items?");
    var MSG_ITEM_IN_CART = _("In your cart");
    var MSG_ITEM_NOT_IN_CART = _("Add to your cart");
//	$("#cartDetails").ready(function(){ $("#cmspan").html("<a href=\"#\" id=\"cartmenulink\" class=\"\"><i><\/i><span><i><\/i><span><\/span><span id=\"carticon\"></span> "+_("Cart")+"<span id=\"basketcount\"><\/span><\/span><\/a>"); });
[% ELSE %]
  [% IF ( virtualshelves ) %]
    var MSG_NO_RECORD_SELECTED = _("No item was selected");
  [% END %]
[% END %]

[% IF ( opacuserlogin ) %]
  [% IF ( TagsEnabled ) %]
    var MSG_TAGS_DISABLED = _("Sorry, tags are not enabled on this system.");
    var MSG_TAG_ALL_BAD = _("Error! Your tag was entirely markup code.  It was NOT added.  Please try again with plain text.");
    var MSG_ILLEGAL_PARAMETER = _("Error! Illegal parameter");
    var MSG_TAG_SCRUBBED = _("Note: your tag contained markup code that was removed. The tag was added as ");
    var MSG_ADD_TAG_FAILED = _("Error! The add_tag operation failed on");
    var MSG_ADD_TAG_FAILED_NOTE = _("Note: you can only tag an item with a given term once.  Check 'My Tags' to see your current tags.");
    var MSG_DELETE_TAG_FAILED = _("Error! You cannot delete the tag");
    var MSG_DELETE_TAG_FAILED_NOTE = _("Note: you can only delete your own tags.")
    var MSG_LOGIN_REQUIRED = _("You must be logged in to add tags.");
    var MSG_TAGS_ADDED = _("Tags added: ");
    var MSG_TAGS_DELETED = _("Tags added: ");
    var MSG_TAGS_ERRORS = _("Errors: ");
    var MSG_MULTI_ADD_TAG_FAILED = _("Unable to add one or more tags.");
  [% END %]
[% END %]
[% IF ( OPACAmazonCoverImages ) %]
    $(window).load(function() {
        verify_images();
    });
[% END %]
[% IF ( SyndeticsCoverImages ) %]
    $(window).load(function() {
        verify_images();
    });
[% END %]
[% IF ( opacuserjs ) %]
    [% opacuserjs %]
[% END %]
	//]]>
</script>
[% IF ( opacbookbag ) %]
[% compose.javascript( src => themelang _ "/js/basket.js" ) %]
[% ELSIF ( virtualshelves ) %]
[% compose.javascript( src => themelang _ "/js/basket.js" ) %]
[% ELSE %]
<script type="text/javascript" language="javascript">var readCookie;</script>
[% END %]

[% IF ( opacuserlogin ) %]
  [% IF ( TagsEnabled ) %]
    [% combine.javascript( src => themelang _ "/js/tags.js" ) %]
  [% END %]
[% END %]

[% IF ( GoogleJackets ) %]
[% combine.javascript( src => themelang _ "/js/google-jackets.js" ) %]
<script type="text/javascript" language="javascript">
	//<![CDATA[
	var NO_GOOGLE_JACKET = _("No cover image available");
	//]]>
</script>
[% END %]
[% IF OpenLibraryCovers %]
[% combine.javascript( src => themelang _ "/js/openlibrary.js" ) %]
<script type="text/javascript" language="javascript">
//<![CDATA[
var NO_OL_JACKET = _("No cover image available");
//]]>
</script>
[% END %]

[% IF OPACLocalCoverImages %]
[% combine.javascript( src => themelang _ "/js/localcovers.js" ) %]
<script type="text/javascript" language="javascript">
//<![CDATA[
var NO_LOCAL_JACKET = _("No cover image available");
//]]>
</script>
[% END %]

[% IF ( BakerTaylorEnabled ) %]
[% combine.javascript( src => themelang _ "/js/bakertaylorimages.js" ) %]
<script type="text/javascript" language="javascript">
	//<![CDATA[
	var NO_BAKERTAYLOR_IMAGE = _("No cover image available");
	$(window).load(function(){
		bt_verify_images();
	});
	//]]>
</script>
[% END %]

<link rel="unapi-server" type="application/xml" title="unAPI" href="[% OPACBaseURL %]/cgi-bin/koha/unapi" />
[% IF ( GoogleIndicTransliteration ) %]
	<script type="text/javascript" src="http://www.google.com/jsapi"></script>
        [% combine.javascript( src => themelang _ "/js/googleindictransliteration.js" ) %]
[% END %]
[% combine.html( prefix => themelang ) %]
