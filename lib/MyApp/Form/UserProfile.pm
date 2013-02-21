package MyApp::Form::UserProfile;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
use namespace::autoclean;

has '+item_class' => (default => 'User');

has_field 'name'          => ( type => 'Text',  required => 1 );
has_field 'email_address' => ( type => 'Email', required => 1 );
has_field 'phone_number'  => ( type => 'Text' );
has_field 'mail_address'  => ( type => 'Text' );

has_field submit => (
   type  => 'Submit',
   value => 'Update'
);

__PACKAGE__->meta->make_immutable;

1;
