use strict;
use warnings;

use Log::Contextual qw{:log with_logger set_logger};
use Log::Contextual::SimpleLogger;
use Test::More qw(no_plan);
my $var1;
my $var2;
my $var3;
my $var_logger1 = Log::Contextual::SimpleLogger->new({
   levels  => [qw(trace debug info warn error fatal)],
   coderef => sub { $var1 = shift },
});

my $var_logger2 = Log::Contextual::SimpleLogger->new({
   levels  => [qw(trace debug info warn error fatal)],
   coderef => sub { $var2 = shift },
});

my $var_logger3 = Log::Contextual::SimpleLogger->new({
   levels  => [qw(trace debug info warn error fatal)],
   coderef => sub { $var3 = shift },
});

SETLOGGER: {
   set_logger(sub { $var_logger3 });
   log_debug { 'set_logger' };
   is( $var3, "[debug] set_logger\n", 'set logger works' );
}

SETLOGGERTWICE: {
   my $foo;
   local $SIG{__WARN__} = sub { $foo = shift };
   set_logger(sub { $var_logger3 });
   like(
      $foo, qr/set_logger \(or -logger\) called more than once!  This is a bad idea! at/,
      'set_logger twice warns correctly'
   );
}

WITHLOGGER: {
   with_logger sub { $var_logger2 } => sub {

      with_logger $var_logger1 => sub {
         log_debug { 'nothing!' }
      };
      log_debug { 'frew!' };

   };

   is( $var1, "[debug] nothing!\n", 'inner scoped logger works' );
   is( $var2, "[debug] frew!\n", 'outer scoped logger works' );
}

SETWITHLOGGER: {
   with_logger $var_logger1 => sub {
      log_debug { 'nothing again!' };
      # do this just so the following set_logger won't warn
      local $SIG{__WARN__} = sub {};
      set_logger(sub { $var_logger3 });
      log_debug { 'this is a set inside a with' };
   };

   is( $var1, "[debug] nothing again!\n",
      'inner scoped logger works after using set_logger'
   );

   is( $var3, "[debug] this is a set inside a with\n",
      'set inside with works'
   );

   log_debug { 'frioux!' };
   is( $var3, "[debug] frioux!\n",
      q{set_logger's logger comes back after scoped logger}
   );
}

VANILLA: {
   log_trace { 'fiSMBoC' };
   is( $var3, "[trace] fiSMBoC\n", 'trace works');

   log_debug { 'fiSMBoC' };
   is( $var3, "[debug] fiSMBoC\n", 'debug works');

   log_info { 'fiSMBoC' };
   is( $var3, "[info] fiSMBoC\n", 'info works');

   log_warn { 'fiSMBoC' };
   is( $var3, "[warn] fiSMBoC\n", 'warn works');

   log_error { 'fiSMBoC' };
   is( $var3, "[error] fiSMBoC\n", 'error works');

   log_fatal { 'fiSMBoC' };
   is( $var3, "[fatal] fiSMBoC\n", 'fatal works');

}

ok(!eval { Log::Contextual->import; 1 }, 'Blank Log::Contextual import dies');

PASSTHROUGH: {
   my @vars;

   @vars = log_trace { 'fiSMBoC: ' . $_[1] } qw{foo bar baz};
   is( $var3, "[trace] fiSMBoC: bar\n", 'log_trace works with input');
   ok( eq_array(\@vars, [qw{foo bar baz}]), 'log_trace passes data through correctly');

   @vars = log_debug { 'fiSMBoC: ' . $_[1] } qw{foo bar baz};
   is( $var3, "[debug] fiSMBoC: bar\n", 'log_debug works with input');
   ok( eq_array(\@vars, [qw{foo bar baz}]), 'log_debug passes data through correctly');

   @vars = log_info { 'fiSMBoC: ' . $_[1] } qw{foo bar baz};
   is( $var3, "[info] fiSMBoC: bar\n", 'log_info works with input');
   ok( eq_array(\@vars, [qw{foo bar baz}]), 'log_info passes data through correctly');

   @vars = log_warn { 'fiSMBoC: ' . $_[1] } qw{foo bar baz};
   is( $var3, "[warn] fiSMBoC: bar\n", 'log_warn works with input');
   ok( eq_array(\@vars, [qw{foo bar baz}]), 'log_warn passes data through correctly');

   @vars = log_error { 'fiSMBoC: ' . $_[1] } qw{foo bar baz};
   is( $var3, "[error] fiSMBoC: bar\n", 'log_error works with input');
   ok( eq_array(\@vars, [qw{foo bar baz}]), 'log_error passes data through correctly');

   @vars = log_fatal { 'fiSMBoC: ' . $_[1] } qw{foo bar baz};
   is( $var3, "[fatal] fiSMBoC: bar\n", 'log_fatal works with input');
   ok( eq_array(\@vars, [qw{foo bar baz}]), 'log_fatal passes data through correctly');



   my $val;
   $val = logS_trace { 'fiSMBoC: ' . $_[0] } 'foo';
   is( $var3, "[trace] fiSMBoC: foo\n", 'logS_trace works with input');
   is( $val, 'foo', 'logS_trace passes data through correctly');

   $val = logS_debug { 'fiSMBoC: ' . $_[0] } 'foo';
   is( $var3, "[debug] fiSMBoC: foo\n", 'logS_debug works with input');
   is( $val, 'foo', 'logS_debug passes data through correctly');

   $val = logS_info { 'fiSMBoC: ' . $_[0] } 'foo';
   is( $var3, "[info] fiSMBoC: foo\n", 'logS_info works with input');
   is( $val, 'foo', 'logS_info passes data through correctly');

   $val = logS_warn { 'fiSMBoC: ' . $_[0] } 'foo';
   is( $var3, "[warn] fiSMBoC: foo\n", 'logS_warn works with input');
   is( $val, 'foo', 'logS_warn passes data through correctly');

   $val = logS_error { 'fiSMBoC: ' . $_[0] } 'foo';
   is( $var3, "[error] fiSMBoC: foo\n", 'logS_error works with input');
   is( $val, 'foo', 'logS_error passes data through correctly');

   $val = logS_fatal { 'fiSMBoC: ' . $_[0] } 'foo';
   is( $var3, "[fatal] fiSMBoC: foo\n", 'logS_fatal works with input');
   is( $val, 'foo', 'logS_fatal passes data through correctly');

   ok(!eval "logS_error { 'frew' } 'bar', 'baz'; 1", 'logS_$level dies from too many args');
}
