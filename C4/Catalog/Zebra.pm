package C4::Catalog::Zebra;
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
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

# Derived from rebuild_zebra.pl (2005-08-11) Paul Poulain and others
# Rewriten 02/03/2011 by Tomas Cohen Arazi (tomascohen@gmail.com)
#                      Universidad Nacional de Cordoba / Argentina

# Library for managing updates in zebra, usually from zebraqueue

use strict;
use warnings;
use C4::Context;
use Getopt::Long;
use File::Temp qw/ tempdir /;
use File::Path;
use Time::HiRes qw(time);
use C4::Biblio;
use C4::AuthoritiesMarc;

use vars qw($VERSION @ISA @EXPORT);

BEGIN {
	# set the version for version checking
	$VERSION = 0.01;

	require Exporter;
	@ISA = qw(Exporter);
	@EXPORT = qw(
		&UpdateAuths
		&UpdateBiblios
		&UpdateAuthsAndBiblios
		&IndexZebraqueueRecords
	);
}


=head1 NAME

C4::Catalog::Zebra

Comment:
	This should be used when merging the rest of the rebuild_zebra.pl indexing logic
	my $nosanitize				= (C4::Context->preference('ZebraNoSanitize')) ? 1 : 0;


=head2 UpdateAuths

  ( $num_records_updated ) = &UpdateAuths ();

returns the number of updated+deleted authority records 

=cut

sub UpdateAuths
{
	# Update authorities
	return IndexZebraqueueRecords('authority');
}

=head2 UpdateBiblios

  ( $num_records_updated ) = &UpdateBiblios ();

returns the number of updated+deleted biblio records 

=cut

sub UpdateBiblios
{
	# Update authorities
	return IndexZebraqueueRecords('biblio');
}

=head2 UpdateAuthsAndBiblios

  ( $num_records_updated ) = &UpdateAuthsAndBiblios ();

returns the number of updated+deleted authority and biblio records 

=cut

sub UpdateAuthsAndBiblios
{
	my $ret;
	# Update authorities
	$ret = UpdateAuths();

	# Update biblios
	$ret += UpdateBiblios();

	return $ret;
}

=head2 IndexZebraqueueRecords

  ( $num_records_updated ) = &IndexZebraqueueRecords ($record_type);

returns the number of updated+deleted $record_type records 

Comment :
$record_type can be either 'biblio' or 'authority'

=cut

sub IndexZebraqueueRecords
{
	my ($record_type) = @_;
	my $as_xml			= (C4::Context->preference('ZebraUseXml')) ? 1 : 0;
	my $noxml			= ($as_xml) ? 0 : 1;
	my $record_format	= ($as_xml) ? 'marcxml' : 'iso2709' ;

	my ($num_records_updated,$num_records_deleted);

	$num_records_deleted = (IndexZebraqueueByAction('deleted',$record_type,$record_format,$as_xml,$noxml)||0);
	$num_records_updated = (IndexZebraqueueByAction('updated',$record_type,$record_format,$as_xml,$noxml)||0);

	return $num_records_deleted + $num_records_updated;
}

=head2 IndexZebraqueueByAction

  ( $num_records_updated ) = &IndexZebraqueueByAction ($action,$record_type,
														$record_format,$as_xml,$noxml);

returns the number of updated+deleted $record_type records 

Comment :
$record_type can be 'biblio' or 'authority'
$record_format can be 'marcxml' or 'iso2709'
$action can be 'updated' or 'deleted'
$as_xml and $noxml are maintained for legacy reasons, one is enough. They
indicate whether to use marcxml for indexing in zebra or iso2709. They should
all be deduced from C4::Context->preference('ZebraUseXml').

=cut

sub IndexZebraqueueByAction
{
	my ($action,$record_type,$record_format,$as_xml,$noxml) = @_;
	my ($num_records_exported,$ret,$zaction);

	if ($action eq 'updated' or $action eq 'deleted') {
		# get records by action
		my $entries = select_zebraqueue_records($record_type, $action);
		# Create tmp dir
		my $directory = File::Temp->newdir();

		# get records from zebraqueue, export to file for zebraidx
		if ($action eq 'updated') {
			$zaction = 'update';
			$num_records_exported = export_marc_records_from_list($record_type, 
												$entries, "$directory", $as_xml, $noxml);
		} else {	
			# $action eq 'deleted'
			$zaction = 'delete';
			$num_records_exported = generate_deleted_marc_records($record_type,
												$entries, "$directory", $as_xml);
		}

		if ($num_records_exported) {
			# log export
			my $time = localtime(time);
			print "$time $num_records_exported $record_type record(s) exported for $zaction\n";
			# TODO error handling / and better logging
			$ret = DoIndexing($record_type,$zaction,"$directory",$record_format);
			if ($ret) {
				print "$time $num_records_exported $record_type record(s) $action\n";
				mark_zebraqueue_batch_done($entries);
				print "$time $num_records_exported $record_type record(s) marked done in zebraqueue\n";
			}
			# /TODO
		}
	} else {
		# Wrong action
		$ret = -1;
	}

	return $ret;
}


sub select_zebraqueue_records {
	my ($record_type, $update_type) = @_;

	my $dbh = C4::Context->dbh;
	my $server = ($record_type eq 'biblio') ? 'biblioserver' : 'authorityserver';
	my $op = ($update_type eq 'deleted') ? 'recordDelete' : 'specialUpdate';

	my $sth = $dbh->prepare(<<'SQL');
		SELECT id, biblio_auth_number 
		FROM zebraqueue
		WHERE server = ?
		AND   operation = ?
		AND   done = 0
		ORDER BY id DESC;
SQL

	$sth->execute($server, $op);
	my $entries = $sth->fetchall_arrayref({});
}

sub mark_zebraqueue_batch_done {
	my ($entries) = @_;

	my $dbh = C4::Context->dbh;

	$dbh->{AutoCommit} = 0;
	my $sth = $dbh->prepare("UPDATE zebraqueue SET done = 1 WHERE id = ?");
	$dbh->commit();
	foreach my $id (map { $_->{id} } @$entries) {
		$sth->execute($id);
	}
	$dbh->{AutoCommit} = 1;
}

sub export_marc_records_from_list {
	my ($record_type, $entries, $directory, $as_xml, $noxml) = @_;
	my $verbose_logging = (C4::Context->preference('ZebraqueueVerboseLogging')) ? 1 : 0;

	my $num_exported = 0;
	open (OUT, ">:utf8 ", "$directory/exported_records") or die $!;
	my $i = 0;
	my %found = ();
	foreach my $record_number ( map { $_->{biblio_auth_number} }
								grep { !$found{ $_->{biblio_auth_number} }++ }
								@$entries ) {
		print "." if ( $verbose_logging );
		print "\r$i" unless ($i++ %100 or !$verbose_logging);
		my ($marc) = get_corrected_marc_record($record_type, $record_number, $noxml);
		if (defined $marc) {
			# FIXME - when more than one record is exported and $as_xml is true,
			# the output file is not valid XML - it's just multiple <record> elements
			# strung together with no single root element.  zebraidx doesn't seem
			# to care, though, at least if you're using the GRS-1 filter.  It does
			# care if you're using the DOM filter, which requires valid XML file(s).
			print OUT ($as_xml) ? $marc->as_xml_record() : $marc->as_usmarc();
			$num_exported++;
		}
	}
	print "\nRecords exported: $num_exported\n" if ( $verbose_logging );
	close OUT;
	return $num_exported;
}

sub generate_deleted_marc_records {
	my ($record_type, $entries, $directory, $as_xml) = @_;
	my $verbose_logging = (C4::Context->preference('ZebraqueueVerboseLogging')) ? 1 : 0;

	my $num_exported = 0;
	open (OUT, ">:utf8 ", "$directory/exported_records") or die $!;
	my $i = 0;
	foreach my $record_number (map { $_->{biblio_auth_number} } @$entries ) {
		print "\r$i" unless ($i++ %100 or !$verbose_logging);
		print "." if ( $verbose_logging );

		my $marc = MARC::Record->new();
		if ($record_type eq 'biblio') {
			fix_biblio_ids($marc, $record_number, $record_number);
		} else {
			fix_authority_id($marc, $record_number);
		}
		if (C4::Context->preference("marcflavour") eq "UNIMARC") {
			fix_unimarc_100($marc);
		}

		print OUT ($as_xml) ? $marc->as_xml_record() : $marc->as_usmarc();
		$num_exported++;
	}
	print "\nRecords exported: $num_exported\n" if ( $verbose_logging );
	close OUT;
	return $num_exported;
}

sub get_corrected_marc_record {
	my ($record_type, $record_number, $noxml) = @_;

	my $marc = get_raw_marc_record($record_type, $record_number, $noxml); 

	if (defined $marc) {
		fix_leader($marc);
		if ($record_type eq 'biblio') {
			my $succeeded = fix_biblio_ids($marc, $record_number);
			return unless $succeeded;
		} else {
			fix_authority_id($marc, $record_number);
		}
		if (C4::Context->preference("marcflavour") eq "UNIMARC") {
			fix_unimarc_100($marc);
		}
	}

	return $marc;
}

sub get_raw_marc_record {
	my ($record_type, $record_number, $noxml) = @_;
	my $dbh = C4::Context->dbh;

	my $marc; 
	if ($record_type eq 'biblio') {
		if ($noxml) {
			my $fetch_sth = $dbh->prepare_cached("SELECT marc FROM biblioitems WHERE biblionumber = ?");
			$fetch_sth->execute($record_number);
			if (my ($blob) = $fetch_sth->fetchrow_array) {
				$marc = MARC::Record->new_from_usmarc($blob);
				$fetch_sth->finish();
			} else {
				return; # failure to find a bib is not a problem -
						# a delete could have been done before
						# trying to process a record update
			}
		} else {
			eval { $marc = GetMarcBiblio($record_number); };
			if ($@) {
				# here we do warn since catching an exception
				# means that the bib was found but failed
				# to be parsed
				warn "error retrieving biblio $record_number";
				return;
			}
		}
	} else {
		eval { $marc = GetAuthority($record_number); };
		if ($@) {
			warn "error retrieving authority $record_number";
			return;
		}
	}
	return $marc;
}

sub fix_leader {
    # FIXME - this routine is suspect
    # It blanks the Leader/00-05 and Leader/12-16 to
    # force them to be recalculated correct when
    # the $marc->as_usmarc() or $marc->as_xml() is called.
    # But why is this necessary?  It would be a serious bug
    # in MARC::Record (definitely) and MARC::File::XML (arguably) 
    # if they are emitting incorrect leader values.
    my $marc = shift;

    my $leader = $marc->leader;
    substr($leader,  0, 5) = '     ';
    substr($leader, 10, 7) = '22     ';
    $marc->leader(substr($leader, 0, 24));
}

sub fix_biblio_ids {
	# FIXME - it is essential to ensure that the biblionumber is present,
	#         otherwise, Zebra will choke on the record.  However, this
	#         logic belongs in the relevant C4::Biblio APIs.
	my $marc = shift;
	my $biblionumber = shift;
	my $biblioitemnumber;
	my $dbh = C4::Context->dbh;

	if (@_) {
		$biblioitemnumber = shift;
	} else {    
		my $sth = $dbh->prepare(
			"SELECT biblioitemnumber FROM biblioitems WHERE biblionumber=?");
		$sth->execute($biblionumber);
		($biblioitemnumber) = $sth->fetchrow_array;
		$sth->finish;
		unless ($biblioitemnumber) {
			warn "failed to get biblioitemnumber for biblio $biblionumber";
			return 0;
		}
	}

	# FIXME - this is cheating on two levels
	# 1. C4::Biblio::_koha_marc_update_bib_ids is meant to be an internal function
	# 2. Making sure that the biblionumber and biblioitemnumber are correct and
	#    present in the MARC::Record object ought to be part of GetMarcBiblio.
	#
	# On the other hand, this better for now than what rebuild_zebra.pl used to
	# do, which was duplicate the code for inserting the biblionumber 
	# and biblioitemnumber
	C4::Biblio::_koha_marc_update_bib_ids($marc, '', $biblionumber, $biblioitemnumber);

	return 1;
}

sub fix_authority_id {
	# FIXME - as with fix_biblio_ids, the authid must be present
	#         for Zebra's sake.  However, this really belongs
	#         in C4::AuthoritiesMarc.
	my ($marc, $authid) = @_;
	unless ($marc->field('001') and $marc->field('001')->data() eq $authid){
		$marc->delete_field($marc->field('001'));
		$marc->insert_fields_ordered(MARC::Field->new('001',$authid));
	}
}

sub fix_unimarc_100 {
	# FIXME - again, if this is necessary, it belongs in C4::AuthoritiesMarc.
	my $marc = shift;

	my $string;
	if ( length($marc->subfield( 100, "a" )) == 35 ) {
		$string = $marc->subfield( 100, "a" );
		my $f100 = $marc->field(100);
		$marc->delete_field($f100);
	}
	else {
		$string = POSIX::strftime( "%Y%m%d", localtime );
		$string =~ s/\-//g;
		$string = sprintf( "%-*s", 35, $string );
	}
	substr( $string, 22, 6, "frey50" );
	unless ( length($marc->subfield( 100, "a" )) == 35 ) {
		$marc->delete_field($marc->field(100));
		$marc->insert_grouped_field(MARC::Field->new( 100, "", "", "a" => $string ));
	}
}

=head2 DoIndexing

  ( $error_code ) = &DoIndexing($record_type,$op,$record_dir,$record_format);

returns the corresponding zebraidx error code

Comment :
$record_type can be 'biblio' or 'authority'
$zaction can be 'delete' or 'update'
$record_dir is the directory where the exported records are
$record_format can be 'marcxml' or 'iso2709'

=cut

sub DoIndexing {
	my ($record_type, $zaction, $record_dir, $record_format) = @_;
	my $zebra_server	= ($record_type eq 'biblio') ? 'biblioserver' : 'authorityserver';
	my $zebra_db_name	= ($record_type eq 'biblio') ? 'biblios' : 'authorities';
	my $zebra_config	= C4::Context->zebraconfig($zebra_server)->{'config'};
	my $zebra_db_dir	= C4::Context->zebraconfig($zebra_server)->{'directory'};
	my $noshadow		= (C4::Context->preference('ZebraNoshadow')) ? '-n' : '';
	my $zebraidx_log_opt		= " -v none,fatal ";

	# TODO better error handling!!
	system("zebraidx -c $zebra_config $zebraidx_log_opt $noshadow -g $record_format -d $zebra_db_name $zaction $record_dir");
	system("zebraidx -c $zebra_config $zebraidx_log_opt -g $record_format -d $zebra_db_name commit") unless $noshadow;
	# /TODO
	
	return 1;
}


END { }

1;
__END__

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

Tomas Cohen Arazi tomascohen@gmail.com

=cut
