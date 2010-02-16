package Log::Contextual;

use 5.006;

$VERSION = '1.000';

require Exporter;

BEGIN { @ISA = qw(Exporter) }

@EXPORT = qw(set_logger log_debug with_logger);

our $Get_Logger;

sub set_logger (&) {
   $Get_Logger = $_[0];
}

sub with_logger (&&) {
   local $Get_Logger = $_[0];
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
