use strict;
use warnings;

use lib 't/lib';
use VarLogger;
use Test::More 'no_plan';

use Log::Contextual qw{:dlog set_logger};

my $var_log =  VarLogger->new;

set_logger(sub { $var_log });
my @foo = Dlog_debug { "Look ma, data: $_" } qw{frew bar baz};
ok( eq_array(\@foo, [qw{frew bar baz}]), 'Dlog_debug passes data through correctly');
is( $var_log->var, <<'OUT', 'Output for Dlog_debug is correct');
Look ma, data: "frew"
"bar"
"baz"
OUT
my $bar = DlogS_debug { "Look ma, data: $_" } [qw{frew bar baz}];
ok( eq_array($bar, [qw{frew bar baz}]), 'DlogS_debug passes data through correctly');
is( $var_log->var, <<'OUT', 'Output for DlogS_debug is correct');
Look ma, data: [
  "frew",
  "bar",
  "baz"
]
OUT

