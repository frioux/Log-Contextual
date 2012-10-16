package Log::Contextual::Role::Router;

use Moo::Role;

requires 'before_import';
requires 'after_import';
requires 'handle_log_request';

1;
