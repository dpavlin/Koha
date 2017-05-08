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
 */

var rainbow_colors = [ '#9400D3', '#4B0082', '#0000FF', '#00FF00', '#FFFF00', '#FF7F00', '#FF0000' ];

function barcode_on_screen(barcode) {
	// FIXME: don't work without checkbox, probably broken
	var found = 0;
	$('table tr td a:contains(130)').each( function(i,o) {
		var possible = $(o).text();
		if ( possible == barcode ) found++;
	})
	var lastchecked = $('div.lastchecked').text();
	if ( lastchecked ) {
		console.info('found lastchecked div', lastchecked);
		var checked_out_barcode = lastchecked.split(/\(/)[1].split(/\)/)[0];
		if ( checked_out_barcode == barcode ) found++;
	}
	// Not checked out message in returns.pl
	var alert_dialog = $('div.alert p a:contains(130)').text();
	if ( alert_dialog ) {
		console.info('found alert dialog', alert_dialog);
		var alert_barcode = alert_dialog.split(/:/)[0];
		if ( alert_barcode == barcode ) found++;
	}
	console.debug('barcode_on_screen', barcode, found);
	return found;
}

var rfid_refresh = 200; // ms
var rfid_count_timeout = 50; // number of times to scan reader before turning off


function rfid_secure_json(t,val, success) {
	if ( t.security.toUpperCase() == val.toUpperCase() ) return success({ verified: val });
	rfid_refresh = 0; // disable rfid pull until secure call returns
	console.log('rfid_secure_json', t, val);
	$.getJSON( '///localhost:9000/secure.js?' + t.sid + '=' + val + ';callback=?', success );
}



var rfid_reset_field = false;
var rfid_current_sid = false;
var rfid_blank_sid   = false;
var rfid_action = undefined;
var rfid_scan_busy = false;

function rfid_scan(data,textStatus) {

	rfid_scan_busy = false;

	var rfid_count = $.cookie('rfid_count');
	if ( rfid_count === undefined ) {
		rfid_count = rfid_count_timeout;
	}

	console.debug( 'rfid_scan', data, 'status', textStatus, 'rfid_count', rfid_count);
	rfid_current_sid = false;
	rfid_blank_sid = false;

	var span = $('span#rfid');

	if ( span.size() == 0 ) {
		// insert last in language bar on bottom
//		span = $('ul#i18nMenu').append('<li><span id=rfid>RFID reader found<span>');

		// alternative pop-up version
		span = $('#breadcrumbs').append('<div id="rfid_popup" style="position: fixed; bottom: 0; right: 0; background: #fff; border: 0.25em solid #ff0; padding: 0.25em; opacity: 0.9; z-index: 1040; font-size: 200%"><label for="rfid_active"><input type=checkbox id="rfid_active"><!-- local_ip -->&nbsp;<span id="rfid">RFID reader</span>&nbsp;<span id="rfid-info"></span></label></div>');
		if ( rfid_count ) $('input#rfid_active').attr('checked',true);
		$('input#rfid_active').click(activate_scan_tags); // FIXME don't activate actions on page load
	}


	if ( span.size() == 0 ) // or before login on top
		span = $('div#login').prepend('<span id=rfid>RFID reader found</span>');

	span = $('span#rfid');
	var info = $('span#rfid-info');


	if ( data.tags ) {
		if ( data.tags.length === 1 ) {
			var t = data.tags[0];
			rfid_current_sid = t.sid;
			var rfid_last_tag = $.cookie('rfid_last_tag');

//			if ( span.text() != t.content ) {
			if ( 1 ) { // force update of security

				var script_name = document.location.pathname.split(/\//).pop();
				var referrer_name = document.referrer.split(/\//).pop();
				var tab_active  = $("#header_search li[aria-selected=true]").attr('aria-controls');
				var focused_form = $('input:focus').first().name;
				var action =
					rfid_action                                                          ? rfid_action :
					( script_name == 'returns.pl'     || tab_active == 'checkin_search') ? 'checkin' : // must be before circulation
					( script_name == 'circulation.pl' || tab_active == 'circ_search' )   ? 'circulation' :
                    'scan';
				rfid_action = undefined; // one-shot
				console.debug('script_name', script_name, 'referrer_name', referrer_name, 'tab_active', tab_active, 'action', action, 'focused_form', focused_form, 'rfid_last_tag' , rfid_last_tag );
				info.text(action);

				// keep refreshing rfid reader
				if ( referrer_name == 'circulation.pl' ) {
					rfid_count = rfid_count_timeout;
				}


				if ( t.content.length == 0 || t.content == 'UUUUUUUUUUUUUUUU' ) { // blank tag (3M is UUU....)

					rfid_blank_sid = t.sid;
					span.text( t.sid + ' blank' ).css('color', 'red' );

				} else if ( t.content.substr(0,3) == '130' && t.reader == '3M810' ) { // books on 3M reader

					var color = 'blue';
					var icon  = '?';
					if ( t.security.toUpperCase() == 'DA' ) { color = 'red'; icon = '&timesb;' }
					if ( t.security.toUpperCase() == 'D7' ) { color = 'green'; icon = '&rarr;' }
					span.html( t.content + '&nbsp;' + icon ).css('color', color);


					if ( tab_active == 'catalog_search'
						&& script_name != 'moredetail.pl'
						&& script_name != 'detail.pl'
						&& $('input#rfid_active').attr('checked') ) {

						if ( $('span.term:contains(bc:'+t.content+')').length == 0 ) {
							$.cookie('rfid_count', rfid_count_timeout);
							rfid_refresh = 0;
							$('input[name=q]')
								.css('background', '#ff0')
								.val( 'bc:' + t.content )
								.closest('form').submit();
						}
					}

					if (
						( action == 'returns' || action == 'checkin' || action == 'circulation' )
						&& ! barcode_on_screen( t.content )
						//&& t.content != rfid_last_tag
					) {
						rfid_reset_field = 'barcode';

						// return must be first to catch change of tab to check-in
						var afi_secure =
							action == 'checkin' ? 'DA' :
							action == 'circulation' ? 'D7' :
							t.security;

						var form_selector =
							script_name == 'returns.pl' ? 'last' : 'first';

						var i = $('input[name=barcode]:focus');
						if ( i.length == 1 ) {
							i.css('background', '#ff0');
							console.log('input barcode focus', i, i.val());
						} else {
							i = $('input[name=barcode]:'+form_selector).first();
							i.css('background', '#ff0');
							console.log('input barcode', form_selector, i, i.val());
						}

						if ( action == 'circulation' && $('#circ_needsconfirmation').length > 0 ) {
							console.log("in circulation, but needs confirmation");
						} else if (i) {

							console.debug('val', i.val(), 'name', i.name, 'i', i);

							if ( i.val() != t.content ) { // && i.name == 'barcode' )  {
								i.css('background', '#0ff' );
								rfid_refresh = 0;
								rfid_secure_json( t, afi_secure, function(data) {
									console.log('secure', afi_secure, data);
									$.cookie('rfid_count', 0); // FIXME once? to see change rfid_count_timeout);
									i.css('background',
											afi_secure == 'DA' ? '#f00' :
											afi_secure == 'D7' ? '#0f0' :
																'#0ff'
										)
										.val( t.content )
										.closest('form').submit();
								});
							} else {
								console.error('not using element', i);
							}
						} else {
							console.error('element not found', i);
						}

					} else {
						console.debug(action, 'no form submit');
					}

				} else if ( t.content.substr(0,3) == '130' ) {

					span.text( 'Please put book on 3M reader!' ).css( 'color', 'red' );

				} else {
					span.html( t.content + '&nbsp;&sstarf;' ).css('color', 'blue' );

					if ( $('.patroninfo:contains('+t.content+')').length == 1 ) {
						console.debug('not submitting', t.contains);
					} else {
						rfid_refresh = 0; // stop rfid scan while submitting form
						rfid_reset_field = 'findborrower';
						$('input[name=findborrower]')
							.css('background', '#00f')
							.val( t.content )
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

	if (rfid_count > 0) rfid_count--;
	if (rfid_count == 0) {
		//span.text('RFID reader disabled').css('color','black');
		$('input#rfid_active').attr('checked', false)
		console.log('RFID disabled', rfid_count);
	}
	$.cookie('rfid_count', rfid_count);

	if (rfid_refresh > 1 && $('input#rfid_active').attr('checked') ) {
		window.setTimeout( function() {
			if ( rfid_refresh ) {
				var color = rainbow_colors[ rfid_count % rainbow_colors.length ];
				console.debug('color', color);
				$('#rfid_popup').css('border','3px solid '+color);
				scan_tags();
			} else {
				console.error('got setTimeout but rfid_refresh', rfid_refresh, ' is not set');
			}
		}, rfid_refresh );
	} else {
		console.debug('rfid_refresh disabled',rfid_refresh);
		$('#rfid_popup').css('border','3px solid #fff');
	}

	$.cookie('rfid_last_tag', t ? t.content : '--none--');

}

function scan_tags() {
	if ( rfid_scan_busy ) {
		console.error('rfid_scan_busy');
		return;
	}
	rfid_scan_busy = true;
	console.info('scan_tags');
	$.getJSON("///localhost:9000/scan?callback=?", rfid_scan);
}

function set_rfid_active(active,action) {
	rfid_action = action;
	var input_active = $('input#rfid_active').attr('checked');
	if ( active && input_active ) {
		$.cookie('rfid_count', rfid_count_timeout);
		console.info('ignored set_rfid_active ', active, action);
		scan_tags();
		return;
	}
	console.info('set_rfid_active', active);
	if ( active ) {
		$.cookie('rfid_count', rfid_count_timeout);
		scan_tags();
		if ( ! input_active ) $('input#rfid_active').attr('checked', true);
	} else {
		if ( input_active ) $('input#rfid_active').attr('checked', false);
		$.cookie('rfid_count', 0);
	}
}

function activate_scan_tags() {
	var active = $('input#rfid_active').attr('checked');
	console.info('activate_scan_tags', active);
	set_rfid_active(active);
}

$(document).ready( function() {
	console.log('rfid_active', $('input#rfid_active').attr('checked') );


	rfid_action = 'scan';
	scan_tags();	// FIXME should we trigger this on page load even if rfid is not active

	// circulation keyboard shortcuts (FFZG specific!)
	shortcut.add('Alt+r', function() { set_rfid_active(true,'checkin'    )});
	shortcut.add('Alt+z', function() { set_rfid_active(true,'circulation')});
	shortcut.add('Alt+y', function() { set_rfid_active(true,'circulation')});
/*
	shortcut.add('Alt+3', function() { set_rfid_active(true,'search?'    )});
	shortcut.add('Alt+4', function() { set_rfid_active(true,'renew'      )}); // renew
*/

	// send RFID tag to currently focused field on screen
	shortcut.add('Alt+s', function() {
		var el = $('input:focus');
		var tag = $('span#rfid').text().split(/\s+/)[0];
		console.log('send', el[0].name, tag, el);
		if ( el && tag ) el.css('background', '#ff0').val( tag )
			;//.closest('form').submit();
	} );

	shortcut.add('F9', function() {
		console.log('F9');
		//set_rfid_active(true,'F9');
		scan_tags();
	});

	// intranet cataloging
	shortcut.add('F4', function() {
		// extract barcode from window title
		var barcode = document.title.split(/\(barcode\s+#|\)/)[1];
		if ( barcode ) {
			if ( ! rfid_blank_sid && rfid_current_sid && confirm('Reprogram this tag to barcode '+barcode) ) {
				rfid_blank_sid = rfid_current_sid;
			}

			console.debug('program barcode', barcode, 'to', rfid_blank_sid);
			$.getJSON( '///localhost:9000/program?' + rfid_blank_sid + '=' + barcode + ';callback=?', function(data) {
				console.info('programmed', rfid_blank_sid, barcode, data);
			});
		} else {
			console.error('no barcode in window title');
		}
	});

});
