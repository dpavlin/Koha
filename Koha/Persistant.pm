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

use Data::Dump qw(dump);

use base 'Exporter';
use version; our $VERSION = qv('1.0.0');

our @EXPORT = (
    qw( sql_cache authorized_value )
);

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
our $stats;

sub _sql_cache {
	my $sql = shift;
	my @var = @_;

	my $key = $sql;
	$key =~ s/\s\s+/ /gs;
	$key = $1 if $key =~ s/^.*\s*--\s*key:\s*(.+)//;
	my $full = join(' ', $key, @var);
	# FIXME make multi-dimensional hash out of this?

	if ( exists $_sql_cache->{$full} ) {
		warn "### _sql_cache HIT $key\n";
		$stats->{$key}->[0]++;
		return $_sql_cache->{$full};
	}
	warn "### _sql_cache MISS $key\n";
	$stats->{$key}->[1]++;
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare( $sql );
	$sth->execute( @var );
	my $v = $sth->fetchrow_hashref;
	$_sql_cache->{$key} = $v;
	warn "# row $key = ",dump($v);
	return $v;
}

=head2 autorhised_value

  my $row = authorised_value( category => $category, $value );

=cut

sub authorised_value {
	shift if $_[0] eq 'category';
	my ( $category, $value ) = @_;
	my $row = _sql_cache("SELECT lib, lib_opac FROM authorised_values WHERE category = ? AND authorised_value = ? -- key:autorhised_value", $category, $value);
	warn dump $row;
	return $row;
}

1;
