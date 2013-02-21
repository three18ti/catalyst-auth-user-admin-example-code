package MyApp::Form::EditUser;

use HTML::FormHandler::Moose;
extends 'MyApp::Form::UserProfile';
use namespace::autoclean;

has_field 'roles' => (
    type         => 'Multiple',
    widget       => 'checkbox_group',
    label_column => 'name',
    label        => '',
);

__PACKAGE__->meta->make_immutable;

1;
