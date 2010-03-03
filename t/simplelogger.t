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

{
   my $cap;
   local *STDERR = do { open my $fh, '>', \$cap; $fh };

   log_debug { 'frew' };
   is($cap, "[debug] frew\n", 'SimpleLogger outputs to STDERR correctly');
}

my $response;
my $l2 = Log::Contextual::SimpleLogger->new({
   levels => [qw{trace debug info warn error fatal}],
   coderef => sub { $response = $_[0] },
});
{
	local $SIG{__WARN__} = sub {}; # do this just to hide warning for tests
	set_logger($l2);
}
log_trace { 'trace' };
is($response, "[trace] trace\n", 'trace renders correctly');
log_debug { 'debug' };
is($response, "[debug] debug\n", 'debug renders correctly');
log_info  { 'info'  };
is($response, "[info] info\n", 'info renders correctly');
log_warn  { 'warn'  };
is($response, "[warn] warn\n", 'warn renders correctly');
log_error { 'error' };
is($response, "[error] error\n", 'error renders correctly');
log_fatal { 'fatal' };
is($response, "[fatal] fatal\n", 'fatal renders correctly');

log_debug { 'line 1', 'line 2' };
is($response, "[debug] line 1\nline 2\n", 'multiline log renders correctly');

