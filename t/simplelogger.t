use strict;
use warnings;

use Log::Contextual::SimpleLogger;
use Log::Contextual qw{:log} => -logger =>
   Log::Contextual::SimpleLogger->new({levels => [qw{debug}]});
use Test::More qw(no_plan);
my $l = Log::Contextual::SimpleLogger->new({levels => [qw{debug}]});

ok($l->is_debug, 'is_debug is true on SimpleLogger');

log_debug { 'set_logger' };
log_trace { die 'this should live' };
