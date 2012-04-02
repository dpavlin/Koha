package Koha::Persistant;

# Copyright (c) 2012 Dobrica Pavlinusic
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

use strict;
use warnings;

use C4::Context;
use Carp qw(confess);
use Data::Dump qw(dump);

use base 'Exporter';
use version; our $VERSION = qv('1.0.0');

our @EXPORT = (
    qw( sql_cache authorised_value marc_subfield_structure )
);

our $debug = $ENV{DEBUG} || 0;

=head1 Persistant

Koha::Persistant - make data objects in Koha persistant

=head1 DESCRIPTION

Koha needs nice centralized way to cache data for plack

Name of this module was choosen to be non-conflicting with possible
future C<Koha::Cache>

=cut

=head2 sql_cache

  $row = sql_cache($sql, $value1 [, $value2, ... ]);

Takes C<SELECT col1,col2 FROM table WHERE value1 = ? AND value2 = ?>
SQL query and cache result returning cached row.

  -- key: name-of-key

Syntax inside SQL query will override default cache key generation
which is simple normalization of SQL strings.

=cut

sub DESTROY {
	warn "## Koha::Persistent::DESTROY";
}

our $_sql_cache;
our $_cache;
our $stats;

sub sql_cache {
	my $sql = shift;
	my @var = @_;

	confess "no variables" unless @var;

	my $cache;

	my $key = $sql;
	$key =~ s/\s\s+/ /gs;
	my $stat_key = $key;

	my $eval;

	if ( $key =~ s/^.*\s*--\s*key:\s*(.+)// ) {
		$stat_key = $1;
		$key = pop @_;
		$eval = '$_cache->{';
		$eval .= dump($_)."}->{" foreach @_;
		$eval =~ s/\Q->{\E$//;
		#warn "# EVAL $eval";
		eval "\$cache = $eval;";
		die $! if $!;
	} else {
		$key = join(' ', $key, @var);
		$cache = $_sql_cache;
	}

	confess "key is undef $sql ",dump(@var) unless defined $key;

	if ( exists $cache->{$key} ) {
		warn "## _sql_cache HIT $key\n" if $debug >= 2;
		$stats->{$stat_key}->[0]++;
		return $cache->{$key};
	}
	warn "## _sql_cache MISS $key\n" if $debug >= 2;
	$stats->{$stat_key}->[1]++;
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare( $sql );
	$sth->execute( @var );
	my $v = $sth->fetchrow_hashref;
	if ( $eval ) {
		eval $eval.'->{'.dump($key).'} = $v;';
	} else {
		$cache->{$key} = $v;
	}
	warn "### row $stat_key $key = ",dump($v) if $debug >= 3;
	return $v;
}

=head2 autorhised_value

  my $row = authorised_value( category => $category, $value );

=cut

sub authorised_value {
	shift if $_[0] eq 'category';
	my ( $category, $value ) = @_;
	my $row = sql_cache("SELECT lib, lib_opac FROM authorised_values WHERE category = ? AND authorised_value = ? -- key:authorised_value", $category, $value);
	warn "## authorised_value $category $value = ",dump $row;
	return $row;
}

=head2 marc_subfield_structure

  my $authorised_value = marc_subfield_structure( kohafield => 'items.notforloan', frameworkcode => 'LIB' );
  my $authorised_value = marc_subfield_structure( tagfield => $tag, tagsubfield => $subfield, frameworkcode => 'LIB' );

=cut

sub marc_subfield_structure {
	my $args = {@_};
	my $row;
	if ( exists $args->{kohafield} && exists $args->{frameworkcode} ) {
		$row = sql_cache("
				SELECT authorised_value
				FROM   marc_subfield_structure
				WHERE  kohafield=?
					AND frameworkcode=?
				-- key:mss_kf_fwc
			", $args->{kohafield}, $args->{frameworkcode});
	} elsif ( exists $args->{tagfield} && exists $args->{tagsubfield} && exists $args->{frameworkcode} ) {
		$row = sql_cache("
				SELECT authorised_value
				FROM   marc_subfield_structure
				WHERE tagfield=?
					AND tagsubfield=?
					AND frameworkcode=?
				-- key:mss_tf_tsf_fwc
			", $args->{tagfield}, $args->{tagsubfield}, $args->{frameworkcode});
	} else {
		confess "called with unknown options ",dump($args)
	}

	warn "## marc_subfield_structure ",dump($args)," = ",dump $row;
	return $row->{authorised_value};
}

1;
