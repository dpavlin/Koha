$(document).ready(function(){

koha_login = $('.loggedinusername').text();
console.log('koha_login', koha_login);

$.getScript('/rfid/register.pl?intranet-js=1&koha_login='+koha_login);

});
