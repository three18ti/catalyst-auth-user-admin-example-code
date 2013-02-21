package MyApp::Form::ChangePassword;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';
use namespace::autoclean;
use Method::Signatures::Simple;

has user => (is => 'rw');

has_field 'current_password' => (
   type     => 'Password',
   label    => 'Current Password',
   required => 1,
);

method validate_current_password($field) {
    $field->add_error('Incorrect password')
        if not $self->user->check_password($field->value);
}

has_field 'new_password' => (
    type      => 'Password',
    label     => 'New Password',
    required  => 1,
    minlength => 5,
);

after validate => method {
    if ($self->field('new_password')->value eq
            $self->field('current_password')->value )
    {
        $self->field('new_password')
            ->add_error('Must be different from current password');
    }
};

has_field 'new_password_conf' => (
   type           => 'PasswordConf',
   label          => 'New Password (again)',
   password_field => 'new_password',
   required       => 1,
   minlength      => 5,
);

has_field submit => (type => 'Submit', value => 'Change');

__PACKAGE__->meta->make_immutable;

1;
