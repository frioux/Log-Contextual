package Log::Contextual::Sugar;

require Exporter;

BEGIN { @ISA = qw(Exporter) }

@EXPORT = qw(Dlog_debug DlogS_debug);

use Data::Dumper::Concise;
use Log::Contextual ();

sub Dlog_trace (&@) {
  my $code = shift;
  my @values = @_;
  Log::Contextual::log_trace {
     do { local $_ = Data::Dumper::Concise::Dumper @values; $code->() };
  };
  @values
}

sub DlogS_trace (&$) {
  my $code = $_[0];
  my $value = $_[1];
   Log::Contextual::log_trace {
     do { local $_ = Data::Dumper::Concise::Dumper $value; $code->() };
  };
  $value
}

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

sub Dlog_info (&@) {
  my $code = shift;
  my @values = @_;
  Log::Contextual::log_info {
     do { local $_ = Data::Dumper::Concise::Dumper @values; $code->() };
  };
  @values
}

sub DlogS_info (&$) {
  my $code = $_[0];
  my $value = $_[1];
   Log::Contextual::log_info {
     do { local $_ = Data::Dumper::Concise::Dumper $value; $code->() };
  };
  $value
}

sub Dlog_warn (&@) {
  my $code = shift;
  my @values = @_;
  Log::Contextual::log_warn {
     do { local $_ = Data::Dumper::Concise::Dumper @values; $code->() };
  };
  @values
}

sub DlogS_warn (&$) {
  my $code = $_[0];
  my $value = $_[1];
   Log::Contextual::log_warn {
     do { local $_ = Data::Dumper::Concise::Dumper $value; $code->() };
  };
  $value
}

sub Dlog_error (&@) {
  my $code = shift;
  my @values = @_;
  Log::Contextual::log_error {
     do { local $_ = Data::Dumper::Concise::Dumper @values; $code->() };
  };
  @values
}

sub DlogS_error (&$) {
  my $code = $_[0];
  my $value = $_[1];
   Log::Contextual::log_error {
     do { local $_ = Data::Dumper::Concise::Dumper $value; $code->() };
  };
  $value
}

sub Dlog_fatal (&@) {
  my $code = shift;
  my @values = @_;
  Log::Contextual::log_fatal {
     do { local $_ = Data::Dumper::Concise::Dumper @values; $code->() };
  };
  @values
}

sub DlogS_fatal (&$) {
  my $code = $_[0];
  my $value = $_[1];
   Log::Contextual::log_fatal {
     do { local $_ = Data::Dumper::Concise::Dumper $value; $code->() };
  };
  $value
}

1;
