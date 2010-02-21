package Log::Contextual;

use strict;
use warnings;

our $VERSION = '0.00100';

require Exporter;
use Data::Dumper::Concise;

BEGIN { our @ISA = qw(Exporter) }

my @dlog = (qw(
   Dlog_debug DlogS_debug
   Dlog_trace DlogS_trace
   Dlog_warn DlogS_warn
   Dlog_info DlogS_info
   Dlog_error DlogS_error
   Dlog_fatal DlogS_fatal
 ));

my @log = (qw(
   log_debug logS_debug
   log_trace logS_trace
   log_warn logS_warn
   log_info logS_info
   log_error logS_error
   log_fatal logS_fatal
 ));

our @EXPORT_OK = (
   @dlog, @log,
   qw( set_logger with_logger )
);

our %EXPORT_TAGS = (
   dlog => \@dlog,
   log  => \@log,
   all  => [@dlog, @log],
);

sub import {
   my $package = shift;
   die 'Log::Contextual does not have a default import list'
      unless @_;

   for my $idx ( 0 .. $#_ ) {
      if ( $_[$idx] eq '-logger' ) {
         set_logger($_[$idx + 1]);
         splice @_, $idx, 2;
         last;
      }
   }
   $package->export_to_level(1, $package, @_);
}

our $Get_Logger;

sub set_logger {
   my $logger = $_[0];
   $logger = do { my $l = $logger; sub { $l } }
      if ref $logger ne 'CODE';
   $Get_Logger = $logger;
}

sub with_logger {
   my $logger = $_[0];
   $logger = do { my $l = $logger; sub { $l } }
      if ref $logger ne 'CODE';
   local $Get_Logger = $logger;
   $_[1]->();
}



sub log_trace (&@) {
   my $log  = $Get_Logger->();
   my $code = shift;
   $log->trace($code->(@_))
      if $log->is_trace;
   @_
}

sub log_debug (&@) {
   my $log  = $Get_Logger->();
   my $code = shift;
   $log->debug($code->(@_))
      if $log->is_debug;
   @_
}

sub log_info (&@) {
   my $log  = $Get_Logger->();
   my $code = shift;
   $log->info($code->(@_))
      if $log->is_info;
   @_
}

sub log_warn (&@) {
   my $log  = $Get_Logger->();
   my $code = shift;
   $log->warn($code->(@_))
      if $log->is_warn;
   @_
}

sub log_error (&@) {
   my $log  = $Get_Logger->();
   my $code = shift;
   $log->error($code->(@_))
      if $log->is_error;
   @_
}

sub log_fatal (&@) {
   my $log  = $Get_Logger->();
   my $code = shift;
   $log->fatal($code->(@_))
      if $log->is_fatal;
   @_
}


sub logS_trace (&$) {
   my $log  = $Get_Logger->();
   my $code = shift;
   my $value = shift;
   $log->trace($code->($value))
      if $log->is_trace;
   $value
}

sub logS_debug (&$) {
   my $log  = $Get_Logger->();
   my $code = shift;
   my $value = shift;
   $log->debug($code->($value))
      if $log->is_debug;
   $value
}

sub logS_info (&$) {
   my $log  = $Get_Logger->();
   my $code = shift;
   my $value = shift;
   $log->info($code->($value))
      if $log->is_info;
   $value
}

sub logS_warn (&$) {
   my $log  = $Get_Logger->();
   my $code = shift;
   my $value = shift;
   $log->warn($code->($value))
      if $log->is_warn;
   $value
}

sub logS_error (&$) {
   my $log  = $Get_Logger->();
   my $code = shift;
   my $value = shift;
   $log->error($code->($value))
      if $log->is_error;
   $value
}

sub logS_fatal (&$) {
   my $log  = $Get_Logger->();
   my $code = shift;
   my $value = shift;
   $log->fatal($code->($value))
      if $log->is_fatal;
   $value
}



sub Dlog_trace (&@) {
  my $code = shift;
  my @values = @_;
  return log_trace {
     if (@values) {
        do { local $_ = Data::Dumper::Concise::Dumper @values; $code->() };
     } else {
        do { local $_ = '()'; $code->() };
     }
  } @values
}

sub Dlog_debug (&@) {
  my $code = shift;
  my @values = @_;
  log_debug {
     if (@values) {
        do { local $_ = Data::Dumper::Concise::Dumper @values; $code->() };
     } else {
        do { local $_ = '()'; $code->() };
     }
  } @values
}

sub Dlog_info (&@) {
  my $code = shift;
  my @values = @_;
  log_info {
     if (@values) {
        do { local $_ = Data::Dumper::Concise::Dumper @values; $code->() };
     } else {
        do { local $_ = '()'; $code->() };
     }
  } @values
}

sub Dlog_warn (&@) {
  my $code = shift;
  my @values = @_;
  log_warn {
     if (@values) {
        do { local $_ = Data::Dumper::Concise::Dumper @values; $code->() };
     } else {
        do { local $_ = '()'; $code->() };
     }
  } @values
}

sub Dlog_error (&@) {
  my $code = shift;
  my @values = @_;
  log_error {
     if (@values) {
        do { local $_ = Data::Dumper::Concise::Dumper @values; $code->() };
     } else {
        do { local $_ = '()'; $code->() };
     }
  } @values
}

sub Dlog_fatal (&@) {
  my $code = shift;
  my @values = @_;
  log_fatal {
     if (@values) {
        do { local $_ = Data::Dumper::Concise::Dumper @values; $code->() };
     } else {
        do { local $_ = '()'; $code->() };
     }
  } @values
}



sub DlogS_trace (&$) {
  my $code = $_[0];
  my $value = $_[1];
  logS_trace {
     do { local $_ = Data::Dumper::Concise::Dumper $value; $code->() };
  } $value
}

sub DlogS_debug (&$) {
  my $code = $_[0];
  my $value = $_[1];
  logS_debug {
     do { local $_ = Data::Dumper::Concise::Dumper $value; $code->() };
  } $value
}

sub DlogS_info (&$) {
  my $code = $_[0];
  my $value = $_[1];
  logS_info {
     do { local $_ = Data::Dumper::Concise::Dumper $value; $code->() };
  } $value
}

sub DlogS_warn (&$) {
  my $code = $_[0];
  my $value = $_[1];
  logS_warn {
     do { local $_ = Data::Dumper::Concise::Dumper $value; $code->() };
  } $value
}

sub DlogS_error (&$) {
  my $code = $_[0];
  my $value = $_[1];
  logS_error {
     do { local $_ = Data::Dumper::Concise::Dumper $value; $code->() };
  } $value
}

sub DlogS_fatal (&$) {
  my $code = $_[0];
  my $value = $_[1];
  logS_fatal {
     do { local $_ = Data::Dumper::Concise::Dumper $value; $code->() };
  } $value
}

1;

__END__

=head1 NAME

Log::Contextual - Simple logging interface with a contextual log

=head1 SYNOPSIS

 use Log::Log4perl;
 use Log::Contextual qw( :log :dlog set_logger with_logger );

 my $logger  = sub { Log::Log4perl->get_logger };

 set_logger { $logger };

 log_debug { 'program started' };

 sub foo {
   with_logger(Log::Contextual::SimpleLogger->new({
       levels => [qw( trace debug )]
     }) => sub {
     log_trace { 'foo entered' };
     my ($foo, $bar) = Dlog_trace { "params for foo: $_" } @_;
     # ...
     log_trace { 'foo left' };
   });
 }

=head1 DESCRIPTION

This module is a simple interface to extensible logging.  It is bundled with a
really basic logger, L<Log::Contextual::SimpleLogger>, but in general you
should use a real logger instead of that.  For something more serious but not
overly complicated, take a look at L<Log::Dispatchouli>.

=head1 OPTIONS

When you import this module you may use C<-logger> as a shortcut for
L<set_logger>, for example:

 use Log::Contextual::SimpleLogger;
 use Log::Contextual qw( :dlog ),
   -logger => Log::Contextual::SimpleLogger->new({ levels => [qw( debug )] });

sometimes you might want to have the logger handy for other stuff, in which
case you might try something like the following:

 my $var_log;
 BEGIN { $var_log = VarLogger->new }
 use Log::Contextual qw( :dlog ), -logger => $var_log;

=head1 A WORK IN PROGRESS

This module is certainly not complete, but we will not break the interface
lightly, so I would say it's safe to use in production code.  The main result
from that at this point is that doing:

 use Log::Contextual;

will die as we do not yet know what the defaults should be.  If it turns out
that nearly everyone uses the C<:log> tag and C<:dlog> is really rare, we'll
probably make C<:log> the default.  But only time and usage will tell.

=head1 FUNCTIONS

=head2 set_logger

 my $logger = WarnLogger->new;
 set_logger $logger;

Arguments: Ref|CodeRef $returning_logger

C<set_logger> will just set the current logger to whatever you pass it.  It
expects a C<CodeRef>, but if you pass it something else it will wrap it in a
C<CodeRef> for you.

=head2 with_logger

 my $logger = WarnLogger->new;
 with_logger $logger => sub {
    if (1 == 0) {
       log_fatal { 'Non Logical Universe Detected' };
    } else {
       log_info  { 'All is good' };
    }
 };

Arguments: Ref|CodeRef $returning_logger, CodeRef $to_execute

C<with_logger> sets the logger for the scope of the C<CodeRef> C<$to_execute>.
As with L<set_logger>, C<with_logger> will wrap C<$returning_logger> with a
C<CodeRef> if needed.

=head2 log_$level

Import Tag: ":log"

Arguments: CodeRef $returning_message

All of the following six functions work the same except that a different method
is called on the underlying C<$logger> object.  The basic pattern is:

 sub log_$level (&) {
   if ($logger->is_$level) {
     $logger->$level(shift->());
   }
 }

=head3 log_trace

 log_trace { 'entered method foo with args ' join q{,}, @args };

=head3 log_debug

 log_debug { 'entered method foo' };

=head3 log_info

 log_info { 'started process foo' };

=head3 log_warn

 log_warn { 'possible misconfiguration at line 10' };

=head3 log_error

 log_error { 'non-numeric user input!' };

=head3 log_fatal

 log_fatal { '1 is never equal to 0!' };

=head2 Dlog_$level

Import Tag: ":dlog"

Arguments: CodeRef $returning_message, @args

All of the following six functions work the same as their L<log_$level>
brethren, except they return what is passed into them and put the stringified
(with L<Data::Dumper::Concise>) version of their args into C<$_>.  This means
you can do cool things like the following:

 my @nicks = Dlog_debug { "names: $_" } map $_->value, $frew->names->all;

and the output might look something like:

 names: "fREW"
 "fRIOUX"
 "fROOH"
 "fRUE"
 "fiSMBoC"

=head3 Dlog_trace

 my ($foo, $bar) = Dlog_trace { "entered method foo with args: $_" } @_;

=head3 Dlog_debug

 Dlog_debug { "random data structure: $_" } { foo => $bar };

=head3 Dlog_info

 return Dlog_info { "html from method returned: $_" } "<html>...</html>";

=head3 Dlog_warn

 Dlog_warn { "probably invalid value: $_" } $foo;

=head3 Dlog_error

 Dlog_error { "non-numeric user input! ($_)" } $port;

=head3 Dlog_fatal

 Dlog_fatal { '1 is never equal to 0!' } 'ZOMG ZOMG' if 1 == 0;

=head2 DlogS_$level

Import Tag: ":dlog"

Arguments: CodeRef $returning_message, Item $arg

All of the following six functions work the same as the related L<Dlog_$level>
functions, except they only take a single scalar after the
C<$returning_message> instead of slurping up (and also setting C<wantarray>)
all the C<@args>

 my $pals_rs = DlogS_debug { "pals resultset: $_" }
   $schema->resultset('Pals')->search({ perlers => 1 });

=head3 DlogS_trace

 my ($foo, $bar) =
   DlogS_trace { "entered method foo with first arg $_" } $_[0], $_[1];

=head3 DlogS_debug

 DlogS_debug { "random data structure: $_" } { foo => $bar };

=head3 DlogS_info

 return DlogS_info { "html from method returned: $_" } "<html>...</html>";

=head3 DlogS_warn

 DlogS_warn { "probably invalid value: $_" } $foo;

=head3 DlogS_error

 DlogS_error { "non-numeric user input! ($_)" } $port;

=head3 DlogS_fatal

 DlogS_fatal { '1 is never equal to 0!' } 'ZOMG ZOMG' if 1 == 0;

=head1 LOGGER INTERFACE

Because this module is ultimately pretty looking glue (glittery?) with the
awesome benefit of the Contextual part, users will often want to make their
favorite logger work with it.  The following are the methods that should be
implemented in the logger:

 is_trace
 is_debug
 is_info
 is_warn
 is_error
 is_fatal
 trace
 debug
 info
 warn
 error
 fatal

The first six merely need to return true if that level is enabled.  The latter
six take the results of whatever the user returned from their coderef and log
them.  For a basic example see L<Log::Contextual::SimpleLogger>.

=head1 AUTHOR

frew - Arthur Axel "fREW" Schmidt <frioux@gmail.com>

=head1 DESIGNER

mst - Matt S. Trout <mst@shadowcat.co.uk>

=head1 COPYRIGHT

Copyright (c) 2010 the Log::Contextual L</AUTHOR> and L</DESIGNER> as listed
above.

=head1 LICENSE

This library is free software and may be distributed under the same terms as
Perl 5 itself.

=cut

