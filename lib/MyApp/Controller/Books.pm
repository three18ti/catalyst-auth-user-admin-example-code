package MyApp::Controller::Books;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller::ActionRole'; }

sub base : Chained('/base') PathPrefix CaptureArgs(0) {}

sub edit : Chained('base') PathPart('') CaptureArgs(0) Does('ACL') AllowedRole('admin') AllowedRole('can_edit') ACLDetachTo('denied') {}

sub list : Chained('base') PathPart('list') Args(0) {
    my ($self, $c) = @_;

    $c->stash(books => [ $c->model('DB::Book')->all ]);
}

sub url_create : Chained('edit') PathPart('url_create') Args(3) {
    my ($self, $c, $title, $rating, $author_id) = @_;

    my $book = $c->model('DB::Book')->create({
        title  => $title,
        rating => $rating
    });

    $book->add_to_book_authors({ author_id => $author_id });

    $c->stash(
        book     => $book,
        template => 'books/create_done.tt2'
    );

    $c->response->header('Cache-Control' => 'no-cache');
}


sub form_create : Chained('edit') PathPart('form_create') Args(0) {
    my ($self, $c) = @_;

    $c->stash(template => 'books/form_create.tt2');
}


sub form_create_do : Chained('edit') PathPart('form_create_do') Args(0) {
    my ($self, $c) = @_;

    my $title     = $c->request->params->{title}     || 'N/A';
    my $rating    = $c->request->params->{rating}    || 'N/A';
    my $author_id = $c->request->params->{author_id} || '1';

    my $book = $c->model('DB::Book')->create({
        title   => $title,
        rating  => $rating,
    });

    $book->add_to_book_authors({author_id => $author_id});

    $c->stash(
        book     => $book,
        template => 'books/create_done.tt2'
    );
}

sub object : Chained('base') PathPart('id') CaptureArgs(1) {
    my ($self, $c, $id) = @_;

    $c->stash(object => $c->model('DB::Book')->find($id));

    die "Book $id not found!" if !$c->stash->{object};
}

sub edit_object : Chained('object') PathPart('') CaptureArgs(0) Does('ACL') AllowedRole('admin') AllowedRole('can_edit') ACLDetachTo('denied') {}

sub delete : Chained('edit_object') PathPart('delete') Args(0) {
    my ($self, $c) = @_;

    $c->stash->{object}->delete;

    $c->res->redirect($c->uri_for($self->action_for('list'),
        {status_msg => "Book deleted."}));
}


sub list_recent : Chained('base') PathPart('list_recent') Args(1) {
    my ($self, $c, $mins) = @_;

    $c->stash(books => [$c->model('DB::Book')
                            ->created_after(DateTime->now->subtract(minutes => $mins))]);

    $c->stash(template => 'books/list.tt2');
}


sub list_recent_tcp : Chained('base') PathPart('list_recent_tcp') Args(1) {
    my ($self, $c, $mins) = @_;

    $c->stash(books => [
            $c->model('DB::Book')
                ->created_after(DateTime->now->subtract(minutes => $mins))
                ->title_like('TCP')
        ]);

    $c->stash(template => 'books/list.tt2');
}

sub denied : Private {
    my ($self, $c) = @_;

    $c->res->redirect($c->uri_for($self->action_for('list'),
        {status_msg => "Access Denied"}));
}

__PACKAGE__->meta->make_immutable;

1;
