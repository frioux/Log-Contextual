use strict;
use warnings;

use Log::Contextual::SimpleLogger;
use Log::Contextual qw{:log set_logger} => -logger =>
   Log::Contextual::SimpleLogger->new({levels => [qw{debug}]});
use Test::More qw(no_plan);
my $l = Log::Contextual::SimpleLogger->new({levels => [qw{debug}]});

ok(!$l->is_trace, 'is_trace is false on SimpleLogger');
ok($l->is_debug, 'is_debug is true on SimpleLogger');
ok(!$l->is_info, 'is_info is false on SimpleLogger');
ok(!$l->is_warn, 'is_warn is false on SimpleLogger');
ok(!$l->is_error, 'is_error is false on SimpleLogger');
ok(!$l->is_fatal, 'is_fatal is false on SimpleLogger');

ok(eval { log_trace { die 'this should live' }; 1}, 'trace does not get called');
ok(!eval { log_debug { die 'this should die' }; 1}, 'debug gets called');
ok(eval { log_info { die 'this should live' }; 1}, 'info does not get called');
ok(eval { log_warn { die 'this should live' }; 1}, 'warn does not get called');
ok(eval { log_error { die 'this should live' }; 1}, 'error does not get called');
ok(eval { log_fatal { die 'this should live' }; 1}, 'fatal does not get called');
