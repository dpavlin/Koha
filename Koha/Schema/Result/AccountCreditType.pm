use utf8;
package Koha::Schema::Result::AccountCreditType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::AccountCreditType

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<account_credit_types>

=cut

__PACKAGE__->table("account_credit_types");

=head1 ACCESSORS

=head2 code

  data_type: 'varchar'
  is_nullable: 0
  size: 80

=head2 description

  data_type: 'varchar'
  is_nullable: 1
  size: 200

=head2 can_be_added_manually

  data_type: 'tinyint'
  default_value: 1
  is_nullable: 0

=head2 is_system

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "code",
  { data_type => "varchar", is_nullable => 0, size => 80 },
  "description",
  { data_type => "varchar", is_nullable => 1, size => 200 },
  "can_be_added_manually",
  { data_type => "tinyint", default_value => 1, is_nullable => 0 },
  "is_system",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</code>

=back

=cut

__PACKAGE__->set_primary_key("code");

=head1 RELATIONS

=head2 account_credit_types_branches

Type: has_many

Related object: L<Koha::Schema::Result::AccountCreditTypesBranch>

=cut

__PACKAGE__->has_many(
  "account_credit_types_branches",
  "Koha::Schema::Result::AccountCreditTypesBranch",
  { "foreign.credit_type_code" => "self.code" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 accountlines

Type: has_many

Related object: L<Koha::Schema::Result::Accountline>

=cut

__PACKAGE__->has_many(
  "accountlines",
  "Koha::Schema::Result::Accountline",
  { "foreign.credit_type_code" => "self.code" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2019-10-14 09:59:52
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Uycu/23b681kWHNX+/gNiw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;