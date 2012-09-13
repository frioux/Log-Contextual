package Log::Contextual::Role::Router;

use Moo::Role;

requires 'before_import';
requires 'after_import';
requires 'get_loggers';

1;
