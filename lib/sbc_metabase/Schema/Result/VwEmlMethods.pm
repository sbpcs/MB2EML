use utf8;
package sbc_metabase::Schema::Result::VwEmlMethods;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

sbc_metabase::Schema::Result::VwEmlMethods

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<vw_eml_methods>

=cut

__PACKAGE__->table("vw_eml_methods");

=head1 ACCESSORS

=head2 datasetid

  data_type: 'integer'
  is_nullable: 1

=head2 entity_sort_order

  data_type: 'integer'
  is_nullable: 1

=head2 column_sort_order

  data_type: 'integer'
  is_nullable: 1

=head2 methodstep_sort_order

  data_type: 'smallint'
  is_nullable: 1

=head2 methodstep

  data_type: 'xml'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "datasetid",
  { data_type => "integer", is_nullable => 1 },
  "entity_sort_order",
  { data_type => "integer", is_nullable => 1 },
  "column_sort_order",
  { data_type => "integer", is_nullable => 1 },
  "methodstep_sort_order",
  { data_type => "smallint", is_nullable => 1 },
  "methodstep",
  { data_type => "xml", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-09-20 09:25:00
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:hbOj/vV0Wrf4Elv8p0qJqw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
