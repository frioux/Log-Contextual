use strict;
use warnings;

use Log::Contextual::SimpleLogger;
use Test::More qw(no_plan);
use Log::Contextual qw(:log set_logger);
my $var;
my @caller_info;
my $var_log = Log::Contextual::SimpleLogger->new({
   levels  => [qw(trace debug info warn error fatal)],
   coderef => sub { chomp($_[0]); $var = "$_[0] at $caller_info[1] line $caller_info[2].\n" }
});
my $warn_faker = sub {
   my ($package, $args) = @_;
   @caller_info = caller($args->{caller_level});
   $var_log
};
set_logger($warn_faker);
log_debug { 'test' };
is($var, "[debug] test at " . __FILE__ . " line " . (__LINE__-1) . ".\n", 'fake warn');
