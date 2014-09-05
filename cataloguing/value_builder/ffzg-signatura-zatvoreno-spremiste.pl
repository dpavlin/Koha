#!/usr/bin/perl

use strict;
use C4::Auth;
use CGI;
use C4::Context;

use C4::Search;
use C4::Output;

=head1 NAME

plugin ffzg-signatura-zatvoreno-spremiste

=head1 SYNOPSIS

generate signatura

=head1 DESCRIPTION

=head1 FUNCTIONS

=over 2

=cut

sub plugin_parameters {
my ($dbh,$record,$tagslib,$i,$tabloop) = @_;
return "";
}

sub plugin_javascript {
	my ($dbh,$record,$tagslib,$field_number,$tabloop) = @_;
	my $function_name= $field_number;
	my $res="
<script type=\"text/javascript\">
//<![CDATA[

function Focus$function_name(subfield_managed) {

/*
	if ( document.getElementById(\"$field_number\").value ) {
	}
	else {
		document.getElementById(\"$field_number\").value='default value for onclick';
	}
*/
    return 1;
}

function Blur$function_name(subfield_managed) {
	return 1;
}

function Clic$function_name(i) {
	defaultvalue=document.getElementById(\"$field_number\").value;
	newin=window.open(\"../cataloguing/plugin_launcher.pl?plugin_name=ffzg-signatura-zatvoreno-spremiste.pl&index=$field_number&result=\"+defaultvalue,\"Odabir signature u zatvorenom spremištu\",'width=800,height=600,toolbar=false,scrollbars=yes');

}
//]]>
</script>
";

	return ($function_name,$res);
}


my $signature = [
	"knjige (formalno signiranje)" => [
		[ "PA 100001-999999", "do 18 cm" ],
		[ "PB 100001-999999", "18,1-25 cm" ],
		[ "PC 100001-999999", "25,1-35 cm" ],
		[ "PD 100001-999999", "iznad 35 cm" ],
		[ "PE 100001-999999", "poprečni format" ],
	],
	"posebne zbirke" => [
		[ "DD 100001-999999", "Doktorske disertacije" ],
		[ "MR 100001-999999", "Magistarski i specijalistički radovi" ],
		[ "DR 100001-999999", "Diplomski i završni radovi" ],
		[ "FO 100001-999999", "Fotokopije" ],
		[ "SE 100001-999999", "Separati" ],
	],
];


sub plugin {
	my ($input) = @_;
	my $index= $input->param('index');
	my $index2= $input->param('index2');
	$index2=-1 unless($index2);
	my $result= $input->param('result');


	my @optgroup;

	while( my $optgroup = shift @$signature ) {

		my $g = { label => $optgroup };

		my $o = shift @$signature;
		foreach my $option ( @$o ) {

			my ( $template, $display ) = @$option;
			push @{ $g->{option} }, { display => $display, value => $template };
		}
		push @optgroup, $g;
	}

	my ($template, $loggedinuser, $cookie)
	= get_template_and_user({template_name => "cataloguing/value_builder/ffzg-signatura-zatvoreno-spremiste.tt",
					query => $input,
					type => "intranet",
					authnotrequired => 0,
					flagsrequired => {editcatalogue => 1},
					debug => 1,
					});
	$template->param(
		index => $index,
		index2 => $index2,
		"f1_$result" => "f1_".$result,
		optgroup => [ @optgroup ],
	);
	output_html_with_http_headers $input, $cookie, $template->output;
}

1;
