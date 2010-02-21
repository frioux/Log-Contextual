use strict;
use warnings;

use lib 't/lib';
use VarLogger;
use Test::More 'no_plan';
my $var_log;

BEGIN { $var_log = VarLogger->new }
use Log::Contextual qw{:dlog}, -logger => $var_log;
{
my @foo = Dlog_trace { "Look ma, data: $_" } qw{frew bar baz};
ok( eq_array(\@foo, [qw{frew bar baz}]), 'Dlog_trace passes data through correctly');
is( $var_log->var, <<'OUT', 'Output for Dlog_trace is correct');
tLook ma, data: "frew"
"bar"
"baz"
OUT

my $bar = DlogS_trace { "Look ma, data: $_" } [qw{frew bar baz}];
ok( eq_array($bar, [qw{frew bar baz}]), 'DlogS_trace passes data through correctly');
is( $var_log->var, <<'OUT', 'Output for DlogS_trace is correct');
tLook ma, data: [
  "frew",
  "bar",
  "baz"
]
OUT
}


{
my @foo = Dlog_debug { "Look ma, data: $_" } qw{frew bar baz};
ok( eq_array(\@foo, [qw{frew bar baz}]), 'Dlog_debug passes data through correctly');
is( $var_log->var, <<'OUT', 'Output for Dlog_debug is correct');
dLook ma, data: "frew"
"bar"
"baz"
OUT

my $bar = DlogS_debug { "Look ma, data: $_" } [qw{frew bar baz}];
ok( eq_array($bar, [qw{frew bar baz}]), 'DlogS_debug passes data through correctly');
is( $var_log->var, <<'OUT', 'Output for DlogS_debug is correct');
dLook ma, data: [
  "frew",
  "bar",
  "baz"
]
OUT
}


{
my @foo = Dlog_info { "Look ma, data: $_" } qw{frew bar baz};
ok( eq_array(\@foo, [qw{frew bar baz}]), 'Dlog_info passes data through correctly');
is( $var_log->var, <<'OUT', 'Output for Dlog_info is correct');
iLook ma, data: "frew"
"bar"
"baz"
OUT

my $bar = DlogS_info { "Look ma, data: $_" } [qw{frew bar baz}];
ok( eq_array($bar, [qw{frew bar baz}]), 'DlogS_info passes data through correctly');
is( $var_log->var, <<'OUT', 'Output for DlogS_info is correct');
iLook ma, data: [
  "frew",
  "bar",
  "baz"
]
OUT
}


{
my @foo = Dlog_warn { "Look ma, data: $_" } qw{frew bar baz};
ok( eq_array(\@foo, [qw{frew bar baz}]), 'Dlog_warn passes data through correctly');
is( $var_log->var, <<'OUT', 'Output for Dlog_warn is correct');
wLook ma, data: "frew"
"bar"
"baz"
OUT

my $bar = DlogS_warn { "Look ma, data: $_" } [qw{frew bar baz}];
ok( eq_array($bar, [qw{frew bar baz}]), 'DlogS_warn passes data through correctly');
is( $var_log->var, <<'OUT', 'Output for DlogS_warn is correct');
wLook ma, data: [
  "frew",
  "bar",
  "baz"
]
OUT
}


{
my @foo = Dlog_error { "Look ma, data: $_" } qw{frew bar baz};
ok( eq_array(\@foo, [qw{frew bar baz}]), 'Dlog_error passes data through correctly');
is( $var_log->var, <<'OUT', 'Output for Dlog_error is correct');
eLook ma, data: "frew"
"bar"
"baz"
OUT

my $bar = DlogS_error { "Look ma, data: $_" } [qw{frew bar baz}];
ok( eq_array($bar, [qw{frew bar baz}]), 'DlogS_error passes data through correctly');
is( $var_log->var, <<'OUT', 'Output for DlogS_error is correct');
eLook ma, data: [
  "frew",
  "bar",
  "baz"
]
OUT
}


{
my @foo = Dlog_fatal { "Look ma, data: $_" } qw{frew bar baz};
ok( eq_array(\@foo, [qw{frew bar baz}]), 'Dlog_fatal passes data through correctly');
is( $var_log->var, <<'OUT', 'Output for Dlog_fatal is correct');
fLook ma, data: "frew"
"bar"
"baz"
OUT

my $bar = DlogS_fatal { "Look ma, data: $_" } [qw{frew bar baz}];
ok( eq_array($bar, [qw{frew bar baz}]), 'DlogS_fatal passes data through correctly');
is( $var_log->var, <<'OUT', 'Output for DlogS_fatal is correct');
fLook ma, data: [
  "frew",
  "bar",
  "baz"
]
OUT
}



{
   my @foo = Dlog_trace { "nothing: $_" } ();
   ok( eq_array(\@foo, []), 'Dlog_trace passes nothing through correctly');
   is( $var_log->var, 'tnothing: ()', 'Output for Dlog_trace is correct');
}

{
   my @foo = Dlog_debug { "nothing: $_" } ();
   ok( eq_array(\@foo, []), 'Dlog_debug passes nothing through correctly');
   is( $var_log->var, 'dnothing: ()', 'Output for Dlog_debug is correct');
}

{
   my @foo = Dlog_info { "nothing: $_" } ();
   ok( eq_array(\@foo, []), 'Dlog_info passes nothing through correctly');
   is( $var_log->var, 'inothing: ()', 'Output for Dlog_info is correct');
}

{
   my @foo = Dlog_warn { "nothing: $_" } ();
   ok( eq_array(\@foo, []), 'Dlog_warn passes nothing through correctly');
   is( $var_log->var, 'wnothing: ()', 'Output for Dlog_warn is correct');
}

{
   my @foo = Dlog_error { "nothing: $_" } ();
   ok( eq_array(\@foo, []), 'Dlog_error passes nothing through correctly');
   is( $var_log->var, 'enothing: ()', 'Output for Dlog_error is correct');
}

{
   my @foo = Dlog_fatal { "nothing: $_" } ();
   ok( eq_array(\@foo, []), 'Dlog_fatal passes nothing through correctly');
   is( $var_log->var, 'fnothing: ()', 'Output for Dlog_fatal is correct');
}

