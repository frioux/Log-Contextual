package WarnLogger;

use POSIX qw(strftime);
sub new { bless {}, __PACKAGE__ }
sub debug {
   my @caller = caller(1);
   my $time = strftime "%y-%m-%d %H:%M:%S", localtime;
   warn "[$time][$caller[0]][$caller[1]][$caller[2]][$_[1]]\n"
}
sub is_debug { 1 }

1;
