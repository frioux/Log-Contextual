use strict;
use warnings;

use Log::Contextual::SimpleLogger;
use Test::More 'no_plan';
my $var_log;
my $var;

BEGIN {
   $var_log = Log::Contextual::SimpleLogger->new({
      levels  => [qw(trace debug info warn error fatal)],
      coderef => sub { $var = shift }
   })
}

use Log::Contextual qw{:dlog}, -logger => $var_log;
{
my @foo = Dlog_trace { "Look ma, data: $_" } qw{frew bar baz};
ok( eq_array(\@foo, [qw{frew bar baz}]), 'Dlog_trace passes data through correctly');
is( $var, <<'OUT', 'Output for Dlog_trace is correct');
[trace] Look ma, data: "frew"
"bar"
"baz"
OUT

my $bar = DlogS_trace { "Look ma, data: $_" } [qw{frew bar baz}];
ok( eq_array($bar, [qw{frew bar baz}]), 'DlogS_trace passes data through correctly');
is( $var, <<'OUT', 'Output for DlogS_trace is correct');
[trace] Look ma, data: [
  "frew",
  "bar",
  "baz"
]
OUT
}


{
my @foo = Dlog_debug { "Look ma, data: $_" } qw{frew bar baz};
ok( eq_array(\@foo, [qw{frew bar baz}]), 'Dlog_debug passes data through correctly');
is( $var, <<'OUT', 'Output for Dlog_debug is correct');
[debug] Look ma, data: "frew"
"bar"
"baz"
OUT

my $bar = DlogS_debug { "Look ma, data: $_" } [qw{frew bar baz}];
ok( eq_array($bar, [qw{frew bar baz}]), 'DlogS_debug passes data through correctly');
is( $var, <<'OUT', 'Output for DlogS_debug is correct');
[debug] Look ma, data: [
  "frew",
  "bar",
  "baz"
]
OUT
}


{
my @foo = Dlog_info { "Look ma, data: $_" } qw{frew bar baz};
ok( eq_array(\@foo, [qw{frew bar baz}]), 'Dlog_info passes data through correctly');
is( $var, <<'OUT', 'Output for Dlog_info is correct');
[info] Look ma, data: "frew"
"bar"
"baz"
OUT

my $bar = DlogS_info { "Look ma, data: $_" } [qw{frew bar baz}];
ok( eq_array($bar, [qw{frew bar baz}]), 'DlogS_info passes data through correctly');
is( $var, <<'OUT', 'Output for DlogS_info is correct');
[info] Look ma, data: [
  "frew",
  "bar",
  "baz"
]
OUT
}


{
my @foo = Dlog_warn { "Look ma, data: $_" } qw{frew bar baz};
ok( eq_array(\@foo, [qw{frew bar baz}]), 'Dlog_warn passes data through correctly');
is( $var, <<'OUT', 'Output for Dlog_warn is correct');
[warn] Look ma, data: "frew"
"bar"
"baz"
OUT

my $bar = DlogS_warn { "Look ma, data: $_" } [qw{frew bar baz}];
ok( eq_array($bar, [qw{frew bar baz}]), 'DlogS_warn passes data through correctly');
is( $var, <<'OUT', 'Output for DlogS_warn is correct');
[warn] Look ma, data: [
  "frew",
  "bar",
  "baz"
]
OUT
}


{
my @foo = Dlog_error { "Look ma, data: $_" } qw{frew bar baz};
ok( eq_array(\@foo, [qw{frew bar baz}]), 'Dlog_error passes data through correctly');
is( $var, <<'OUT', 'Output for Dlog_error is correct');
[error] Look ma, data: "frew"
"bar"
"baz"
OUT

my $bar = DlogS_error { "Look ma, data: $_" } [qw{frew bar baz}];
ok( eq_array($bar, [qw{frew bar baz}]), 'DlogS_error passes data through correctly');
is( $var, <<'OUT', 'Output for DlogS_error is correct');
[error] Look ma, data: [
  "frew",
  "bar",
  "baz"
]
OUT
}


{
my @foo = Dlog_fatal { "Look ma, data: $_" } qw{frew bar baz};
ok( eq_array(\@foo, [qw{frew bar baz}]), 'Dlog_fatal passes data through correctly');
is( $var, <<'OUT', 'Output for Dlog_fatal is correct');
[fatal] Look ma, data: "frew"
"bar"
"baz"
OUT

my $bar = DlogS_fatal { "Look ma, data: $_" } [qw{frew bar baz}];
ok( eq_array($bar, [qw{frew bar baz}]), 'DlogS_fatal passes data through correctly');
is( $var, <<'OUT', 'Output for DlogS_fatal is correct');
[fatal] Look ma, data: [
  "frew",
  "bar",
  "baz"
]
OUT
}



{
   my @foo = Dlog_trace { "nothing: $_" } ();
   ok( eq_array(\@foo, []), 'Dlog_trace passes nothing through correctly');
   is( $var, "[trace] nothing: ()\n", 'Output for Dlog_trace is correct');
}

{
   my @foo = Dlog_debug { "nothing: $_" } ();
   ok( eq_array(\@foo, []), 'Dlog_debug passes nothing through correctly');
   is( $var, "[debug] nothing: ()\n", 'Output for Dlog_debug is correct');
}

{
   my @foo = Dlog_info { "nothing: $_" } ();
   ok( eq_array(\@foo, []), 'Dlog_info passes nothing through correctly');
   is( $var, "[info] nothing: ()\n", 'Output for Dlog_info is correct');
}

{
   my @foo = Dlog_warn { "nothing: $_" } ();
   ok( eq_array(\@foo, []), 'Dlog_warn passes nothing through correctly');
   is( $var, "[warn] nothing: ()\n", 'Output for Dlog_warn is correct');
}

{
   my @foo = Dlog_error { "nothing: $_" } ();
   ok( eq_array(\@foo, []), 'Dlog_error passes nothing through correctly');
   is( $var, "[error] nothing: ()\n", 'Output for Dlog_error is correct');
}

{
   my @foo = Dlog_fatal { "nothing: $_" } ();
   ok( eq_array(\@foo, []), 'Dlog_fatal passes nothing through correctly');
   is( $var, "[fatal] nothing: ()\n", 'Output for Dlog_fatal is correct');
}

