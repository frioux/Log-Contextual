use strict;
use warnings;

use lib 't/lib';
use VarLogger;
use Log::Contextual qw{:log with_logger set_logger};
use Test::More qw(no_plan);
my $var_logger1 =  VarLogger->new;
my $var_logger2 =  VarLogger->new;
my $var_logger3 = VarLogger->new;

WITHLOGGER: {
   with_logger sub { $var_logger2 } => sub {

      with_logger $var_logger1 => sub {
         log_debug { 'nothing!' }
      };
      log_debug { 'frew!' };

   };

   is( $var_logger1->var, 'nothing!', 'inner scoped logger works' );
   is( $var_logger2->var, 'frew!', 'outer scoped logger works' );
}

SETLOGGER: {
   set_logger(sub { $var_logger3 });
   log_debug { 'set_logger' };
   is( $var_logger3->var, 'set_logger', 'set logger works' );
}

SETWITHLOGGER: {
   with_logger $var_logger1 => sub {
      log_debug { 'nothing again!' }
   };

   is( $var_logger1->var, 'nothing again!',
      'inner scoped logger works after using set_logger'
   );

   log_debug { 'frioux!' };
   is( $var_logger3->var, 'frioux!',
      q{set_logger's logger comes back after scoped logger}
   );
}
