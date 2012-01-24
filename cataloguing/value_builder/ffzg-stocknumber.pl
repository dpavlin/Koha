#!/usr/bin/perl

# Copyright 2010 BibLibre SARL
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
use warnings;
use C4::Auth;
use CGI;
use C4::Context;

=head1 DESCRIPTION

This plugin is specific to FFZG but could be used as a base for similar operations.
It is used for stocknumber computation.

If the user send an empty string, we return a simple incremented stocknumber for current year.
If a prefix is submited, we look for the highest stocknumber with this prefix, and return it incremented.
In this case, a stocknumber has this form : "YEAR-0009678570".
 - YEAR is numeric 4-digit year, like 2012
 - dash
 - digits, without leading zero

Required database changes:

  create unique index item_stocknumer on items(stocknumber) ;

  create table ffzg_inventarna_knjiga (
	id int not null auto_increment primary key,
	year int not null,
	num int not null,
	biblionumber int not null,
	last_update timestamp default current_timestamp on update current_timestamp,
	unique index ffzg_inv_br(year,num)
  ) ;

=cut

sub plugin_parameters {
}

sub plugin_javascript {
    my ($dbh,$record,$tagslib,$field_number,$tabloop) = @_;

    my $res="
    <script type='text/javascript'>
        function Focus$field_number() {
            return 1;
        }

        function Blur$field_number() {
                return 1;
        }

        function Clic$field_number() {
                var code = document.getElementById('$field_number');

		if ( ! confirm('Jeste li sigurni da želite dodijeliti novi inventarni broj?') )
			return;

                var url = '../cataloguing/plugin_launcher.pl?plugin_name=ffzg-stocknumber.pl&code=' + code.value;
                var blurcallbackstocknumber = {
                    success: function(o) {
                        var field = document.getElementById('$field_number');
                        field.value = o.responseText;
                        return 1;
                    }
                }
                var transaction = YAHOO.util.Connect.asyncRequest('GET',url, blurcallbackstocknumber, null);
            return 1;
        }
    </script>
    ";

    return ($field_number,$res);
}

sub plugin {
    my ($input) = @_;


    my $code = $input->param('code');
	my ( $year, $num ) = split(/-/,$code);

    $year = (localtime)[5] + 1900 unless $year;

warn "XXX plugin code = $code";

    my ($template, $loggedinuser, $cookie) = get_template_and_user({
        template_name   => "cataloguing/value_builder/ajax.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => {editcatalogue => '*'},
        debug           => 1,
    });

	if ( ! $num ) {

			my $dbh = C4::Context->dbh;

			$dbh->begin_work;

			my $sth = $dbh->prepare("select max(num) from ffzg_inventarna_knjiga where year = ?");
			$sth->execute($year);

			my $max = $sth->fetchrow; # return null without any data
			$max += 1;

			$sth = $dbh->prepare("insert into ffzg_inventarna_knjiga (year,num) values (?,?)");
			$sth->execute( $year, $max );

			$dbh->commit;

			$num = $max;

	}

	$template->param(
		return => $year . '-' . $num,
	);

    output_html_with_http_headers $input, $cookie, $template->output;
}

1;
