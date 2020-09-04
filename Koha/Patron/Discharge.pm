package Koha::Patron::Discharge;

use Modern::Perl;
use CGI;
use File::Temp qw( :POSIX );
use Carp;

use C4::Templates qw ( gettemplate );
use C4::Letters qw ( GetPreparedLetter );

use Koha::Database;
use Koha::DateUtils qw( dt_from_string output_pref );
use Koha::Patrons;
use Koha::Patron::Debarments;

sub count {
    my ($params) = @_;
    my $values = {};

    if( $params->{borrowernumber} ) {
        $values->{borrower} = $params->{borrowernumber};
    }
    if( $params->{pending} ) {
        $values->{needed} = { '!=', undef };
        $values->{validated} = undef;
    }
    elsif( $params->{validated} ) {
        $values->{validated} = { '!=', undef };
    }

    return search_limited( $values )->count;
}

sub can_be_discharged {
    my ($params) = @_;
    return unless $params->{borrowernumber};

    my $patron = Koha::Patrons->find( $params->{borrowernumber} );
    return unless $patron;

    my $has_pending_checkouts = $patron->checkouts->count;
    return $has_pending_checkouts ? 0 : 1;
}

sub is_discharged {
    my ($params) = @_;
    return unless $params->{borrowernumber};
    my $borrowernumber = $params->{borrowernumber};

    my $restricted = Koha::Patrons->find( $borrowernumber )->is_debarred;
    my @validated = get_validated({borrowernumber => $borrowernumber});

    if ($restricted && @validated) {
        return 1;
    } else {
        return 0;
    }
}

sub request {
    my ($params) = @_;
    my $borrowernumber = $params->{borrowernumber};
    return unless $borrowernumber;
    return unless can_be_discharged({ borrowernumber => $borrowernumber });

    my $rs = Koha::Database->new->schema->resultset('Discharge');
    return $rs->create({
        borrower => $borrowernumber,
        needed   => dt_from_string,
    });
}

sub discharge {
    my ($params) = @_;
    my $borrowernumber = $params->{borrowernumber};
    return unless $borrowernumber and can_be_discharged( { borrowernumber => $borrowernumber } );

    # Cancel reserves
    my $patron = Koha::Patrons->find( $borrowernumber );
    my $holds = $patron->holds;
    while ( my $hold = $holds->next ) {
        $hold->cancel;
    }

    # Debar the member
    Koha::Patron::Debarments::AddDebarment({
        borrowernumber => $borrowernumber,
        type           => 'DISCHARGE',
    });

    # Generate the discharge
    my $rs = Koha::Database->new->schema->resultset('Discharge');
    my $discharge = $rs->search({ borrower => $borrowernumber }, { order_by => { -desc => 'needed' }, rows => 1 });
    if( $discharge->count > 0 ) {
        $discharge->update({ validated => dt_from_string });
    }
    else {
        $rs->create({
            borrower  => $borrowernumber,
            validated => dt_from_string,
        });
    }

	# FIXME -- dpavlin - added discharge mail

my $loggedinuser = C4::Context->userenv->{'number'} || 0;

use Data::Dump qw(dump);
warn "XXX discharge for $borrowernumber from logged user $loggedinuser";

my $dbh = C4::Context->dbh;
my $sth = $dbh->prepare(qq{
select
	firstname, surname, userid,
	ba1.attribute as jmbag,
	ba2.attribute as oib
from borrowers b
left outer join borrower_attributes ba1 on (b.borrowernumber = ba1.borrowernumber and ba1.code='JMBAG')
left outer join borrower_attributes ba2 on (b.borrowernumber = ba2.borrowernumber and ba2.code='OIB')
where b.borrowernumber = ?
});
$sth->execute( $borrowernumber );

my $row = $sth->fetchrow_hashref;

my $sth_ffzg = $dbh->prepare(qq{
insert into ffzg_discharges (
	discharge_id,
	borrower,
	needed,
	validated,
	firstname,
	surname,
	userid,
	jmbag,
	oib,
	k_borrowernumber,
	k_firstname,
	k_surname,
	k_userid
)
select
	discharge_id,
	borrower,
	needed,
	validated,
	b.firstname,
	b.surname,
	b.userid,
	ba1.attribute as jmbag,
	ba2.attribute as oib,
	kb.borrowernumber as k_borrowernumber,
	kb.firstname as k_firstname,
	kb.surname as k_surname,
	kb.userid as k_userid
from discharges
join borrowers b on (b.borrowernumber = borrower)
left outer join borrower_attributes ba1 on (b.borrowernumber = ba1.borrowernumber and ba1.code='JMBAG')
left outer join borrower_attributes ba2 on (b.borrowernumber = ba2.borrowernumber and ba2.code='OIB')
left outer join borrowers kb on (kb.borrowernumber = ?)
where borrower = ? and validated is not null
order by validated desc limit 1

});
$sth_ffzg->execute( $loggedinuser, $borrowernumber );

warn "XXX discharge row for $borrowernumber = ", Data::Dump::dump( $row );

my $dbh = C4::Context->dbh;
my $sth = $dbh->prepare(qq{
select *
from ffzg_discharges
where borrower = ?
order by validated desc limit 1
});
$sth->execute( $borrowernumber );

my $row = $sth->fetchrow_hashref;

warn "XXX discharge mail for $borrowernumber row = ",dump( $row );
my $substitute = {};
$substitute-> { 'ffzg_discharges.' . $_ } = $row->{$_} foreach ( keys %$row );
warn "YYY substitute = ", dump( $substitute );

    my $patron = Koha::Patrons->find( $borrowernumber );
    my $letter = C4::Letters::GetPreparedLetter(
        module      => 'members',
        letter_code => 'DISCHARGE',
        lang        => $patron->lang,
        tables      => { borrowers => $borrowernumber, },
        substitute  => $substitute, ## FIXME dpavlin -- add arbitrary params
    );

    my $today = output_pref( dt_from_string() );
    $letter->{'title'}   =~ s/<<today>>/$today/g;
    $letter->{'content'} =~ s/<<today>>/$today/g;
	my $body = $letter->{content};
	$body =~ s{</?[^>]+>}{}gs;

open(my $mail, '|-', '/usr/sbin/sendmail -t -f knjiznica@ffzg.hr');
binmode $mail, ':encoding(utf-8)';
print $mail qq{From: Knjiznica vracene sve knjige <knjiznica\@ffzg.hr>
To: dpavlin+koha-discharge\@ffzg.hr, mglavica+koha-discharge\@ffzg.hr, dilicic+vracene-knjige\@ffzg.hr
Subject: vracene knjige OIB: $row->{oib} JMBAG: $row->{jmbag}

$body
};
close($mail);


}

sub generate_as_pdf {
    my ($params) = @_;
    return unless $params->{borrowernumber};

# FIXME dpavlin -- added new fields
use Data::Dump qw(dump);

my $borrowernumber = $params->{borrowernumber};
my $dbh = C4::Context->dbh;
my $sth = $dbh->prepare(qq{
select *
from ffzg_discharges
where borrower = ?
order by validated desc limit 1
});
$sth->execute( $borrowernumber );

my $row = $sth->fetchrow_hashref;

warn "XXX discharge pdf for $borrowernumber row = ",dump( $row );
my $substitute = {};
$substitute-> { 'ffzg_discharges.' . $_ } = $row->{$_} foreach ( keys %$row );
warn "YYY substitute = ", dump( $substitute );

    my $patron = Koha::Patrons->find( $params->{borrowernumber} );
    my $letter = C4::Letters::GetPreparedLetter(
        module      => 'members',
        letter_code => 'DISCHARGE',
        lang        => $patron->lang,
        tables      => { borrowers => $params->{borrowernumber}, branches => $params->{'branchcode'}, },
        substitute  => $substitute, ## FIXME dpavlin -- add arbitrary params
    );

    my $today = output_pref( dt_from_string() );
    $letter->{'title'}   =~ s/<<today>>/$today/g;
    $letter->{'content'} =~ s/<<today>>/$today/g;

    my $tmpl = C4::Templates::gettemplate('batch/print-notices.tt', 'intranet', new CGI);
    $tmpl->param(
        stylesheet => C4::Context->preference("NoticeCSS"),
        today      => $today,
        messages   => [$letter],
    );

    my $html_path = tmpnam() . '.html';
    my $pdf_path = tmpnam() . '.pdf';
    my $html_content = $tmpl->output;
    open my $html_fh, '>:encoding(utf8)', $html_path;
    say $html_fh $html_content;
    close $html_fh;
    my $output = eval { require PDF::FromHTML; return; } || $@;
    if ($output && $params->{testing}) {
        carp $output;
        $pdf_path = undef;
    }
    elsif ($output) {
        die $output;
    }
    else {
        my $pdf = PDF::FromHTML->new( encoding => 'utf-8' );
        $pdf->load_file( $html_path );

        my $ttf = C4::Context->config('ttf');
        if ( $ttf  && exists $ttf->{font} ) {

            my $type2path;
            foreach my $font ( @{ $ttf->{font} } ) {
                    $type2path->{ $font->{type} } = $font->{content};
            }

            $pdf->convert(
                FontBold          => $type2path->{'HB'} || 'HelveticaBold',
                FontOblique       => $type2path->{'HO'} || 'HelveticaOblique',
                FontBoldOblique   => $type2path->{'HBO'}|| 'HelveticaBoldOblique',
                FontUnicode       => $type2path->{'H'}  || 'Helvetica',
                Font              => $type2path->{'H'}  || 'Helvetica',
            );
        } else {
            $pdf->convert();
        }
        $pdf->write_file( $pdf_path );
    }

    return $pdf_path;
}

sub get_pendings {
    my ($params)       = @_;
    my $branchcode     = $params->{branchcode};
    my $borrowernumber = $params->{borrowernumber};

    my $cond = {
        'me.needed'    => { '!=', undef },
        'me.validated' => undef,
        ( defined $borrowernumber ? ( 'me.borrower' => $borrowernumber ) : () ),
        ( defined $branchcode ? ( 'borrower.branchcode' => $branchcode ) : () ),
    };

    return search_limited( $cond );
}

sub get_validated {
    my ($params)       = @_;
    my $branchcode     = $params->{branchcode};
    my $borrowernumber = $params->{borrowernumber};

    my $cond = {
        'me.validated' => { '!=', undef },
        ( defined $borrowernumber ? ( 'me.borrower' => $borrowernumber ) : () ),
        ( defined $branchcode ? ( 'borrower.branchcode' => $branchcode ) : () ),
    };

    return search_limited( $cond );
}

# TODO This module should be based on Koha::Object[s]
sub search_limited {
    my ( $params, $attributes ) = @_;
    my $userenv = C4::Context->userenv;
    my @restricted_branchcodes;
    if ( $userenv and $userenv->{number} ) {
        my $logged_in_user = Koha::Patrons->find( $userenv->{number} );
        @restricted_branchcodes = $logged_in_user->libraries_where_can_see_patrons;
    }
    $params->{'borrower.branchcode'} = { -in => \@restricted_branchcodes } if @restricted_branchcodes;
    $attributes->{join} = 'borrower';

    my $rs = Koha::Database->new->schema->resultset('Discharge');
    return $rs->search( $params, { join => 'borrower' } );
}

1;
