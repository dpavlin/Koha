/*
 * RFID support for Koha
 *
 * Writtern by Dobrica Pavlinusic <dpavlin@rot13.org> under GPL v2 or later
 *
 * This provides example how to intergrate JSONP interface from
 *
 * scripts/RFID-JSONP-server.pl
 *
 * to provide overlay for tags in range and emulate form fill for Koha Library System
 * which allows check-in and checkout-operations without touching html interface
 *
 * You will have to inject remote javascript in Koha intranetuserjs using:

// inject JavaScript RFID support
$.getScript('http://localhost:9000/examples/koha-rfid.js');

 */

function barcode_on_screen(barcode) {
	var found = 0;
	$('table tr td a:contains(130)').each( function(i,o) {
		var possible = $(o).text();
		if ( possible == barcode ) found++;
	})
	return found;
}

var rfid_refresh = 1500; // ms

function rfid_secure_json(t,val, success) {
	if ( t.security.toUpperCase() == val.toUpperCase() ) return;
	rfid_refresh = 0; // disable rfid pull until secure call returns
	console.log('rfid_secure_json', t, val);
	$.getJSON( 'http://localhost:9000/secure.js?' + t.sid + '=' + val + ';callback=?', success );
}

function rfid_secure_check(t,val) {
	if ( barcode_on_screen(t.content) ) {
		rfid_secure_json(t, val);
	}
}


var rfid_reset_field = false;
var rfid_current_sid = false;
var rfid_blank_sid   = false;

function rfid_scan(data,textStatus) {

	console.debug( 'rfid_scan', data, textStatus );
	rfid_current_sid = false;
	rfid_blank_sid = false;

	var span = $('span#rfid');

	if ( span.size() == 0 ) // insert last in language bar on bottom
//		span = $('ul#i18nMenu').append('<li><span id=rfid>RFID reader found<span>');
		span = $('#breadcrumbs').append('<div id="rfid_popup" style="position: fixed; bottom: 0; right: 0; background: #fff; border: 3px solid #ff0; padding: 1em; opacity: 0.7; z-index: 10;"><span id="rfid">RFID reader</span></div>');

	if ( span.size() == 0 ) // or before login on top
		span = $('div#login').prepend('<span id=rfid>RFID reader found</span>');

	span = $('span#rfid');


	if ( data.tags ) {
		if ( data.tags.length === 1 ) {
			var t = data.tags[0];
			rfid_current_sid = t.sid;

//			if ( span.text() != t.content ) {
			if ( 1 ) { // force update of security

				var script_name = document.location.pathname.split(/\//).pop();
//				var tab_active  = $("#header_search .ui-tabs-panel:not(.ui-tabs-hide)").prop('id');
				var tab_active  = $("#header_search li[aria-selected=true]").attr('aria-controls');
				console.debug('tab_active', tab_active);
				var circulation = script_name == 'circulation.pl' || tab_active == 'circ_search' ;
				var returns     = script_name == 'returns.pl' || tab_active == 'checkin_search';

				if ( t.content.length == 0 || t.content == 'UUUUUUUUUUUUUUUU' ) { // blank tag (3M is UUU....)

					rfid_blank_sid = t.sid;
					span.text( t.sid + ' blank' ).css('color', 'red' );

				} else if ( t.content.substr(0,3) == '130' && t.reader == '3M810' ) { // books on 3M reader

					var color = 'blue';
					if ( t.security.toUpperCase() == 'DA' ) color = 'red';
					if ( t.security.toUpperCase() == 'D7' ) color = 'green';
					span.text( t.content ).css('color', color);


					if ( tab_active == 'catalog_search' && script_name != 'moredetail.pl' ) {
						if ( $('span.term:contains(bc:'+t.content+')').length == 0 ) {
							$('input[name=q]').val( 'bc:' + t.content ).closest('form').submit();
						}
					}

					if ( ! barcode_on_screen( t.content ) || returns ) {
						rfid_reset_field = 'barcode';

						// return must be first to catch change of tab to check-in
						var afi_secure    = returns ? 'DA' : 'D7';
						var form_selector = returns ? 'first' : 'last';
						if ( returns || circulation ) {
							var i = $('input[name=barcode]:'+form_selector);
							if ( i.val() != t.content )  {
								rfid_secure_json( t, afi_secure, function(data) {
									console.log('secure', afi_secure, data);
									i.val( t.content ).closest('form').submit();
								});
							}
						} else {
							console.error('not in circulation or returns');
						}
					}

				} else if ( t.content.substr(0,3) == '130' ) {

					span.text( 'Please put book on 3M reader!' ).css( 'color', 'red' );

				} else {
					span.text( t.content ).css('color', 'blue' );

					if ( $('.patroninfo:contains('+t.content+')').length == 1 ) {
						console.debug('not submitting', t.contains);
					} else {
						rfid_refresh = 0; // stop rfid scan while submitting form
						rfid_reset_field = 'findborrower';
						$('input[name=findborrower]').val( t.content )
							.parent().submit();
					}
				}
			}
		} else {
			var error = data.tags.length + ' tags near reader: ';
			$.each( data.tags, function(i,tag) { error += tag.content + ' '; } );
			span.text( error ).css( 'color', 'red' );
		}

	} else {
		span.text( 'no tags in range' ).css('color','gray');
		if ( rfid_reset_field ) {
			$('input[name='+rfid_reset_field+']').val( '' );
			rfid_reset_field = false;
		}
	}

	if (rfid_refresh > 1) {
		window.setTimeout( function() {
			$.getJSON("http://localhost:9000/scan?callback=?", rfid_scan);
		}, rfid_refresh );
	} else {
		console.debug('rfid_refresh disabled',rfid_refresh);
	}
}

$(document).ready( function() {
	$.getJSON("http://localhost:9000/scan?callback=?", rfid_scan);

	shortcut.add('F4', function() {
		// extract barcode from window title
		var barcode = document.title.split(/\(barcode\s+#|\)/)[1];
		if ( barcode ) {
			if ( ! rfid_blank_sid && rfid_current_sid && confirm('Reprogram this tag to barcode '+barcode) ) {
				rfid_blank_sid = rfid_current_sid;
			}

			console.debug('program barcode', barcode, 'to', rfid_blank_sid);
			$.getJSON( 'http://localhost:9000/program?' + rfid_blank_sid + '=' + barcode + ';callback=?', function(data) {
				console.info('programmed', rfid_blank_sid, barcode, data);
			});
		} else {
			console.error('no barcode in window title');
		}
	});

});
