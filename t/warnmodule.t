use strict;
use warnings;

use Log::Contextual qw{:log set_logger};
use Log::Contextual::SimpleLogger;
use Test::More qw(no_plan);

my $var;
my $var_logger = Log::Contextual::SimpleLogger->new({
   levels  => [qw(trace debug info warn error fatal)],
   coderef => sub { $var = shift },
});

{
   package Doz;
   use Log::Contextual qw{:log}, -default_logger => 'warn';

   sub new {
      log_debug { 'doz' };
   }
}

Doz->new;
is( $var, undef, 'logging disabled by default' );

{
   my $w;
   local $SIG{__WARN__} = sub { $w = shift };

   $ENV{DOZ_DEBUG} = 1;
   Doz->new;
   is( $w, "[debug] doz\n", "logging enabled, warning emitted" );
}

set_logger($var_logger);
Doz->new;
is( $var, "[debug] doz\n", "logger set, logging catched" );

