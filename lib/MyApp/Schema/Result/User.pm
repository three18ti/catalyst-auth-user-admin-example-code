use utf8;
package MyApp::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

MyApp::Schema::Result::User

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::TimeStamp>

=item * L<DBIx::Class::PassphraseColumn>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "PassphraseColumn");

=head1 TABLE: C<users>

=cut

__PACKAGE__->table("users");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 active

  data_type: 'char'
  is_nullable: 0
  size: 1

=head2 username

  data_type: 'text'
  is_nullable: 0

=head2 password

  data_type: 'text'
  is_nullable: 0

=head2 password_expires

  data_type: 'timestamp'
  is_nullable: 1

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 email_address

  data_type: 'text'
  is_nullable: 0

=head2 phone_number

  data_type: 'text'
  is_nullable: 1

=head2 mail_address

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "active",
  { data_type => "char", is_nullable => 0, size => 1 },
  "username",
  { data_type => "text", is_nullable => 0 },
  "password",
  { data_type => "text", is_nullable => 0 },
  "password_expires",
  { data_type => "timestamp", is_nullable => 1 },
  "name",
  { data_type => "text", is_nullable => 0 },
  "email_address",
  { data_type => "text", is_nullable => 0 },
  "phone_number",
  { data_type => "text", is_nullable => 1 },
  "mail_address",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<username_unique>

=over 4

=item * L</username>

=back

=cut

__PACKAGE__->add_unique_constraint("username_unique", ["username"]);

=head1 RELATIONS

=head2 user_roles

Type: has_many

Related object: L<MyApp::Schema::Result::UserRole>

=cut

__PACKAGE__->has_many(
  "user_roles",
  "MyApp::Schema::Result::UserRole",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 roles

Type: many_to_many

Composing rels: L</user_roles> -> role

=cut

__PACKAGE__->many_to_many("roles", "user_roles", "role");


# Created by DBIx::Class::Schema::Loader v0.07015 @ 2011-12-14 13:06:41
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:XqRcULNcWHOHnJ2UsP8t3Q

__PACKAGE__->add_columns(
    '+password' => {
        passphrase       => 'rfc2307',
        passphrase_class => 'BlowfishCrypt',
        passphrase_args  => {
            cost        => 14,
            salt_random => 20,
        },
        passphrase_check_method => 'check_password',
    }
);

__PACKAGE__->meta->make_immutable;

1;
