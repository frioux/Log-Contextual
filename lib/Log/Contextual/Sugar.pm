package Log::Contextual::Sugar;

require Exporter;

BEGIN { @ISA = qw(Exporter) }

@EXPORT = qw(Dlog_debug DlogS_debug);

use Data::Dumper::Concise;
use Log::Contextual ();

sub Dlog_debug (&@) {
  my $code = shift;
  my @values = @_;
  Log::Contextual::log_debug {
     do { local $_ = Data::Dumper::Concise::Dumper @values; $code->() };
  };
  @values
}

sub DlogS_debug (&$) {
  my $code = $_[0];
  my $value = $_[1];
   Log::Contextual::log_debug {
     do { local $_ = Data::Dumper::Concise::Dumper $value; $code->() };
  };
  $value
}

1;
