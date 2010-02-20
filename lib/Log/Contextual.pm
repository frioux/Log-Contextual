package Log::Contextual;

use strict;
use warnings;

our $VERSION = '1.000';

require Exporter;
use Data::Dumper::Concise;

BEGIN { our @ISA = qw(Exporter) }

my @dlog = (qw{
   Dlog_debug DlogS_debug
   Dlog_trace DlogS_trace
   Dlog_warn DlogS_warn
   Dlog_info DlogS_info
   Dlog_error DlogS_error
   Dlog_fatal DlogS_fatal
});

my @log = (qw{
   log_debug
   log_trace
   log_warn
   log_info
   log_error
   log_fatal
});

our @EXPORT_OK = (
   @dlog, @log,
   qw{set_logger with_logger}
);

our %EXPORT_TAGS = (
   dlog => \@dlog,
   log  => \@log,
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

sub log_trace (&) {
   my $log = $Get_Logger->();
   $log->trace($_[0]->())
      if $log->is_trace;
}

sub log_debug (&) {
   my $log = $Get_Logger->();
   $log->debug($_[0]->())
      if $log->is_debug;
}

sub log_info (&) {
   my $log = $Get_Logger->();
   $log->info($_[0]->())
      if $log->is_info;
}

sub log_warn (&) {
   my $log = $Get_Logger->();
   $log->warn($_[0]->())
      if $log->is_warn;
}

sub log_error (&) {
   my $log = $Get_Logger->();
   $log->error($_[0]->())
      if $log->is_error;
}

sub log_fatal (&) {
   my $log = $Get_Logger->();
   $log->fatal($_[0]->())
      if $log->is_fatal;
}



sub Dlog_trace (&@) {
  my $code = shift;
  my @values = @_;
  log_trace {
     do { local $_ = Data::Dumper::Concise::Dumper @values; $code->() };
  };
  @values
}

sub DlogS_trace (&$) {
  my $code = $_[0];
  my $value = $_[1];
  log_trace {
     do { local $_ = Data::Dumper::Concise::Dumper $value; $code->() };
  };
  $value
}

sub Dlog_debug (&@) {
  my $code = shift;
  my @values = @_;
  log_debug {
     do { local $_ = Data::Dumper::Concise::Dumper @values; $code->() };
  };
  @values
}

sub DlogS_debug (&$) {
  my $code = $_[0];
  my $value = $_[1];
  log_debug {
     do { local $_ = Data::Dumper::Concise::Dumper $value; $code->() };
  };
  $value
}

sub Dlog_info (&@) {
  my $code = shift;
  my @values = @_;
  log_info {
     do { local $_ = Data::Dumper::Concise::Dumper @values; $code->() };
  };
  @values
}

sub DlogS_info (&$) {
  my $code = $_[0];
  my $value = $_[1];
  log_info {
     do { local $_ = Data::Dumper::Concise::Dumper $value; $code->() };
  };
  $value
}

sub Dlog_warn (&@) {
  my $code = shift;
  my @values = @_;
  log_warn {
     do { local $_ = Data::Dumper::Concise::Dumper @values; $code->() };
  };
  @values
}

sub DlogS_warn (&$) {
  my $code = $_[0];
  my $value = $_[1];
  log_warn {
     do { local $_ = Data::Dumper::Concise::Dumper $value; $code->() };
  };
  $value
}

sub Dlog_error (&@) {
  my $code = shift;
  my @values = @_;
  log_error {
     do { local $_ = Data::Dumper::Concise::Dumper @values; $code->() };
  };
  @values
}

sub DlogS_error (&$) {
  my $code = $_[0];
  my $value = $_[1];
  log_error {
     do { local $_ = Data::Dumper::Concise::Dumper $value; $code->() };
  };
  $value
}

sub Dlog_fatal (&@) {
  my $code = shift;
  my @values = @_;
  log_fatal {
     do { local $_ = Data::Dumper::Concise::Dumper @values; $code->() };
  };
  @values
}

sub DlogS_fatal (&$) {
  my $code = $_[0];
  my $value = $_[1];
  log_fatal {
     do { local $_ = Data::Dumper::Concise::Dumper $value; $code->() };
  };
  $value
}

1;

__END__

=head1 NAME

Log::Contextual - Super simple logging interface

=head1 SYNOPSIS

 use Log::Contextual;

 my $logger  = WarnLogger->new;
 my $logger2 = FileLogger->new;

 set_logger { $logger };

 log_debug { "program started" };

 sub foo {
   with_logger {
     log_trace { "foo entered" };
     # ...
     log_trace { "foo left"    };
   } $logger2;
 }

=head1 DESCRIPTION

This module is for simplistic but very extensible logging.

=head1 FUNCTIONS

=head2 set_logger

 my $logger = WarnLogger->new;
 set_logger { $logger };

Arguments: CodeRef $returning_logger

=head2 with_logger

 my $logger = WarnLogger->new;
 with_logger { $logger } sub {
    if (1 == 0) {
       log_fatal { 'Non Logical Universe Detected' };
    } else {
       log_info  { 'All is good' };
    }
 };

Arguments: CodeRef $to_execute, CodeRef $returning_logger

=head2 log_trace

 log_trace { 'entered method foo with args ' join q{,}, @args };

Arguments: CodeRef $returning_message

=head2 log_debug

 log_debug { 'entered method foo' };

Arguments: CodeRef $returning_message

=head2 log_info

 log_info { 'started process foo' };

Arguments: CodeRef $returning_message

=head2 log_warn

 log_warn { 'possible misconfiguration at line 10' };

Arguments: CodeRef $returning_message

=head2 log_error

 log_error { 'non-numeric user input!' };

Arguments: CodeRef $returning_message

=head2 log_fatal

 log_fatal { '1 is never equal to 0!' };

Arguments: CodeRef $returning_message

=head1 SUGARY SYNTAX

This package also provides:

L<Log::Contextual::Sugar> - provides Dlog_$level and DlogS_$level convenience
functions

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

.:13:03:05:. <@mst> amazing how simple this stuff is once you get the paradigm
.:13:03:13:. <@mst> also consider
.:13:04:17:. <@mst> package Catalyst::Plugin::LogContextual; use Moose::Role; around
                    handle_request => sub { my ($orig, $self) = (shift, shift); my @args = @_;
                    with_logger { $self->log } sub { $self->$orig(@args) } };
