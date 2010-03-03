use strict;
use warnings;

use Test::More;

if (!eval "use Log::Log4perl; 1") {
   plan skip_all => 'Log::Log4perl not installed'
} else {
   plan tests => 2;
}

use FindBin;
unlink 'myerrs.log' if -e 'myerrs.log';
Log::Log4perl->init("$FindBin::Bin/log4perl.conf");
use Log::Contextual qw( :log set_logger );
set_logger(Log::Log4perl->get_logger);

log_error { 'err 14' };

sub foo {
   log_error { 'err 17' };
}
foo();
open my $log, '<', 'myerrs.log';
my @datas = <$log>;
close $log;

is $datas[0], "file:t/log4perl.t line:18 method:main:: - err 14\n", 'file and line work with Log4perl';
is $datas[1], "file:t/log4perl.t line:21 method:main::foo - err 17\n", 'file and line work with Log4perl in a sub';

