package MyApp::Controller::Root;
use Moose;
use namespace::autoclean;
use DateTime;

BEGIN { extends 'Catalyst::Controller' }

__PACKAGE__->config(namespace => '');

sub base : Chained('/login/required') PathPart('') CaptureArgs(0) {
    my ($self, $c) = @_;

    if ($c->action ne $c->controller('User')->action_for('change_password')
        && $c->user_exists
        && $c->user->password_expires
        && $c->user->password_expires <= DateTime->now)
    {
        $c->res->redirect($c->uri_for('/user/change_password', {
            status_msg => 'Password Expired'
        }));
        $c->detach;
    }
}

sub home : Chained('/base') PathPart('') Args(0) {
    my ($self, $c) = @_;

    $c->res->redirect($c->uri_for('/books/list'));
}

sub default : Chained('/base') PathPart('') Args {
    my ($self, $c) = @_;
    $c->res->body('Page not found');
    $c->res->status(404);
}

sub end : ActionClass('RenderView') {}

__PACKAGE__->meta->make_immutable;

1;
