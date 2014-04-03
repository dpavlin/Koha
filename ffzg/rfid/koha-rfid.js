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

function rfid_scan(data,textStatus) {

	console.debug( 'rfid_scan', data, textStatus );

	var span = $('span#rfid');

	if ( span.size() == 0 ) // insert last in language bar on bottom
		span = $('ul#i18nMenu').append('<li><span id=rfid>RFID reader found<span>');

	if ( span.size() == 0 ) // or before login on top
		span = $('div#login').prepend('<span id=rfid>RFID reader found</span>');

	span = $('span#rfid');


	if ( data.tags ) {
		if ( data.tags.length === 1 ) {
			var t = data.tags[0];
//			if ( span.text() != t.content ) {
			if ( 1 ) { // force update of security

				var script_name = document.location.pathname.split(/\//).pop();
				var tab_active  = $("#header_search .ui-tabs-panel:not(.ui-tabs-hide)").prop('id');
				var circulation = script_name == 'circulation.pl';
				var returns     = script_name == 'returns.pl' || tab_active == 'checkin_search';

				if ( t.content.length == 0 ) { // empty tag

					span.text( t.sid + ' empty' ).css('color', 'red' );

				} else if ( t.content.substr(0,3) == '130' ) { // books

					var color = 'blue';
					if ( t.security.toUpperCase() == 'DA' ) color = 'red';
					if ( t.security.toUpperCase() == 'D7' ) color = 'green';
					span.text( t.content ).css('color', color);

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
});
