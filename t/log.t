use strict;
use warnings;

use Log::Contextual;
use Test::More qw(no_plan);
my $logger = sub { WarnLogger->new };

set_logger($logger);
log_debug { 'frew!' };



BEGIN {
   package WarnLogger;
   sub debug { warn $_[1] }
   sub is_debug { 1 }
   sub new { bless {}, __PACKAGE__ }
}
