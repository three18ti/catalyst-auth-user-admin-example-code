#!/usr/bin/env perl

use strict;
use warnings;
use lib 'lib';

BEGIN { $ENV{CATALYST_DEBUG} = 0 }

use MyApp;
use DateTime;

my $admin = MyApp->model('DB::User')->search({ username => 'admin' })
    ->single;

$admin->update({ password => 'admin', password_expires => DateTime->now });
