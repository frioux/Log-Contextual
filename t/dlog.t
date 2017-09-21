use strict;
use warnings;

use Log::Contextual::SimpleLogger;
use Test::More 'no_plan';
my $var_log;
my $var;

my @levels = qw(debug trace warn info error fatal);

BEGIN {
   $var_log = Log::Contextual::SimpleLogger->new({
         levels  => [qw(trace debug info warn error fatal)],
         coderef => sub { $var = shift }
      })
}

use Log::Contextual qw{:dlog}, -logger => $var_log;

for my $level (@levels) {

   my @foo =
     main->can("Dlog_$level")->(sub { "Look ma, data: $_" }, qw{frew bar baz});
   ok(
      eq_array(\@foo, [qw{frew bar baz}]),
      "Dlog_$level passes data through correctly"
   );
   is(
      $var,
      qq([$level] Look ma, data: "frew"\n"bar"\n"baz"\n),
      "Output for Dlog_$level is correct"
   );

   my $bar =
     main->can("DlogS_$level")
     ->(sub { "Look ma, data: $_" }, [qw{frew bar baz}]);
   ok(
      eq_array($bar, [qw{frew bar baz}]),
      'DlogS_trace passes data through correctly'
   );
   like(
      $var,
      qr(\[$level\] Look ma, data: \[),
      "Output for DlogS_$level is correct"
   );

   @foo = main->can("Dlog_$level")->(sub { "nothing: $_" }, ());
   ok(eq_array(\@foo, []), "Dlog_$level passes nothing through correctly");
   is($var, "[$level] nothing: ()\n", "Output for Dlog_$level is correct");

   local $TODO = "DlogS currently doesn't pass 'nothing' correctly";

   @foo = main->can("DlogS_$level")->(sub { "nothing: $_" }, ());
   ok(eq_array(\@foo, []), "Dlog_$level passes nothing through correctly");
   is($var, "[$level] nothing: ()\n", "Output for Dlog_$level is correct");
}

