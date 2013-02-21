package MyApp::Form::AddUser;

use HTML::FormHandler::Moose;
extends 'MyApp::Form::EditUser';
use namespace::autoclean;

has_field 'username' => (
    type     => 'Text',
    label    => 'User name',
    required => 1,
);

__PACKAGE__->meta->make_immutable;

1;
