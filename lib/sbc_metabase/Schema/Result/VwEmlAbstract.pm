use utf8;
package sbc_metabase::Schema::Result::VwEmlAbstract;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

sbc_metabase::Schema::Result::VwEmlAbstract

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<vw_eml_abstract>

=cut

__PACKAGE__->table("vw_eml_abstract");

=head1 ACCESSORS

=head2 datasetid

  data_type: 'integer'
  is_nullable: 1

=head2 abstract

  data_type: 'xml'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "datasetid",
  { data_type => "integer", is_nullable => 1 },
  "abstract",
  { data_type => "xml", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-09-30 13:23:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:aysrvDKQ+bZll0RzVNI5Tg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
