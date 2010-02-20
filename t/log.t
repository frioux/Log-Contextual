use strict;
use warnings;

use lib 't/lib';
use VarLogger;
use Log::Contextual qw{:log with_logger set_logger};
use Test::More qw(no_plan);
my $var_logger1 = VarLogger->new;
my $var_logger2 = VarLogger->new;
my $var_logger3 = VarLogger->new;

WITHLOGGER: {
   with_logger sub { $var_logger2 } => sub {

      with_logger $var_logger1 => sub {
         log_debug { 'nothing!' }
      };
      log_debug { 'frew!' };

   };

   is( $var_logger1->var, 'dnothing!', 'inner scoped logger works' );
   is( $var_logger2->var, 'dfrew!', 'outer scoped logger works' );
}

SETLOGGER: {
   set_logger(sub { $var_logger3 });
   log_debug { 'set_logger' };
   is( $var_logger3->var, 'dset_logger', 'set logger works' );
}

SETWITHLOGGER: {
   with_logger $var_logger1 => sub {
      log_debug { 'nothing again!' };
      set_logger(sub { $var_logger3 });
      log_debug { 'this is a set inside a with' };
   };

   is( $var_logger1->var, 'dnothing again!',
      'inner scoped logger works after using set_logger'
   );

   is( $var_logger3->var, 'dthis is a set inside a with',
      'set inside with works'
   );

   log_debug { 'frioux!' };
   is( $var_logger3->var, 'dfrioux!',
      q{set_logger's logger comes back after scoped logger}
   );
}

VANILLA: {
   log_trace { 'fiSMBoC' };
   is( $var_logger3->var, 'tfiSMBoC', 'trace works');

   log_debug { 'fiSMBoC' };
   is( $var_logger3->var, 'dfiSMBoC', 'debug works');

   log_info { 'fiSMBoC' };
   is( $var_logger3->var, 'ifiSMBoC', 'info works');

   log_warn { 'fiSMBoC' };
   is( $var_logger3->var, 'wfiSMBoC', 'warn works');

   log_error { 'fiSMBoC' };
   is( $var_logger3->var, 'efiSMBoC', 'error works');

   log_fatal { 'fiSMBoC' };
   is( $var_logger3->var, 'ffiSMBoC', 'fatal works');

}

ok(!eval { Log::Contextual->import; 1 }, 'Blank Log::Contextual import dies');
