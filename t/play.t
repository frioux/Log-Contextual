use strict;
use warnings;

use lib 't/lib';
use WarnLogger;
use Log::Contextual;
use Test::More qw(no_plan);

my $logger =  WarnLogger->new;

set_logger { $logger };
log_debug { 'set_logger' };
log_debug { 'simple log 1' };
log_debug { 'simple log 2' };
sleep 1;
log_debug { 'simple log 3' };

