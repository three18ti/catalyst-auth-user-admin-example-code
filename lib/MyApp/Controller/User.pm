package MyApp::Controller::User;
use Moose;
use namespace::autoclean;
use Crypt::PassGen 'passgen';
use MyApp::Form::AddUser        ();
use MyApp::Form::EditUser       ();
use MyApp::Form::ChangePassword ();
use MyApp::Form::UserProfile    ();

BEGIN { extends 'Catalyst::Controller::ActionRole'; }

sub base : Chained('/base') PathPrefix CaptureArgs(0) {}

sub admin : Chained('base') PathPart('') CaptureArgs(0) Does('ACL') RequiresRole('admin') ACLDetachTo('denied') {}

sub change_password : Chained('base') PathPart('change_password') Args(0) {
    my ($self, $c) = @_;

    my $form = MyApp::Form::ChangePassword->new;

    $c->stash(form => $form);

    return unless $form->process(
        user   => $c->user,
        params => $c->req->body_parameters,
    );

    $c->user->update({
        password         => $form->field('new_password')->value,
        password_expires => undef,
    });

    $c->res->redirect($c->uri_for('/books/list', {
        status_msg => 'Password changed successfully'
    }));
}

sub profile : Chained('base') PathPart('profile') Args(0) {
    my ($self, $c) = @_;

    my $form = MyApp::Form::UserProfile->new;

    $c->stash(form => $form);

    return unless $form->process(
        schema  => $c->model('DB')->schema,
        item_id => $c->user->id,
        params  => $c->req->body_parameters,
    );

    $c->res->redirect($c->uri_for('/books/list', {
        status_msg => 'Profile Updated'
    }));
}

sub list : Chained('admin') PathPart('list') Args(0) {
    my ($self, $c) = @_;

    my $users = $c->model('DB::User')->search(
        { active => 'Y'},
        {
            order_by => ['username'],
            page     => ($c->req->param('page') || 1),
            rows     => 20,
        }
    );

    $c->stash(
        users => $users,
        pager => $users->pager,
    );
}

sub add : Chained('admin') PathPart('add') Args(0) {
    my ($self, $c) = @_;

    my $form = MyApp::Form::AddUser->new;

    $c->stash(form => $form);

    my $user = $c->model('DB::User')->new_result({});

    my ($temp_password) = passgen(NWORDS => 1, NLETT => 8);

    $user->password($temp_password);
    $user->password_expires(DateTime->now);
    $user->active('Y');

    return unless $form->process(
        schema => $c->model('DB')->schema,
        item   => $user,
        params => $c->req->body_parameters,
    );

    $c->stash->{email} = {
        to           => $user->email_address,
        from         => 'admin@myapp.org',
        subject      => 'Welcome to MyApp',
        content_type => 'text/html',
        template     => 'welcome.tt2',
    };

    $c->stash(
        username => $user->username,
        password => $temp_password,
    );

    $c->forward($c->view('Email::Template'));

    $c->res->redirect($c->uri_for($self->action_for('list'), {
        status_msg => 'User '
            . $user->username
            . ' created successfully'
            . ', initial password emailed ' . 'to '
            . $user->email_address
    }));
}

sub user : Chained('admin') PathPart('') CaptureArgs(1) {
    my ($self, $c, $user_id) = @_;

    $c->stash(user => $c->model('DB::User')->find($user_id));
}

sub inactivate : Chained('user') PathPart('inactivate') Args(0) {
    my ($self, $c) = @_;

    my $user = $c->stash->{user};

    $user->update({ active => 'N' });

    my $username = $user->username;

    $c->res->redirect($c->uri_for($self->action_for('list'), {
        status_msg => "User $username inactivated"
    }));
}

sub reset_password : Chained('user') PathPart('reset_password') Args(0) {
    my ($self, $c) = @_;

    my $user = $c->stash->{user};

    my ($temp_password) = passgen(NWORDS => 1, NLETT => 8);

    $user->password($temp_password);
    $user->password_expires(DateTime->now);
    $user->update;

    $c->stash->{email} = {
        to           => $user->email_address,
        from         => 'admin@myapp.org',
        subject      => 'Your MyApp Password has been Reset',
        content_type => 'text/html',
        template     => 'reset_password.tt2',
    };

    $c->stash(
        username => $user->username,
        password => $temp_password,
    );

    $c->forward($c->view('Email::Template'));

    $c->res->redirect($c->uri_for($self->action_for('list'), {
        status_msg => 'Password reset email for '
            . $user->username
            . ' sent to '
            . $user->email_address
    }));
}

sub edit : Chained('user') PathPart('edit') Args(0) {
    my ($self, $c) = @_;

    my $form = MyApp::Form::EditUser->new;

    $c->stash(form => $form);

    return unless $form->process(
        schema  => $c->model('DB')->schema,
        item_id => $c->stash->{user}->id,
        params  => $c->req->body_parameters,
    );

    $c->res->redirect($c->uri_for($self->action_for('list'), {
        status_msg => 'User '
            . $c->stash->{user}->username
            . ' updated successfully'
    }));
}

sub denied : Private {
    my ($self, $c) = @_;

    $c->res->redirect($c->uri_for('/books/list', {
        status_msg => "Access Denied"
    }));
}

__PACKAGE__->meta->make_immutable;

1;
