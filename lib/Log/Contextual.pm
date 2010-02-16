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

sub with_logger (&$) {
   local $Get_Logger = $_[1];
   $_[0]->();
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
 with_logger {
    if (1 == 0) {
       log_fatal { 'Non Logical Universe Detected' };
    } else {
       log_info  { 'All is good' };
    }
 }, sub { $logger};

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

.:12:44:33:. <@mst> we have a $Get_Logger global that contains a subref
.:12:45:11:. <@mst> sub log_debug (&) { my $log = $Get_Logger->(); if ($log->is_debug) {
                    $log->debug($_[0]->()} } }
.:13:01:22:. >>@mst<< frew: the other part is we'll need a set_logger function that's global
.:13:01:26:. >>@mst<< frew: plus a with_logger function
.:13:01:33:. >>@mst<< frew: that uses local()
.:13:01:38:. <@mst> that should be enough to make a start
.:13:01:48:. <@frew> so with_logger is what gives us context?
.:13:01:57:. <@mst> right
.:13:02:09:. <@mst> with_logger { $logger }, sub { <run code> };
.:13:02:29:. <@mst> sub with_logger { local $Get_Logger = $_[0]; $_[1]->() }
.:13:03:05:. <@mst> amazing how simple this stuff is once you get the paradigm
.:13:03:13:. <@mst> also consider
.:13:04:17:. <@mst> package Catalyst::Plugin::LogContextual; use Moose::Role; around
                    handle_request => sub { my ($orig, $self) = (shift, shift); my @args = @_;
                    with_logger { $self->log } sub { $self->$orig(@args) } };
.:13:03:43:. <@frew> so why is $G_L a subref instead of just a ref?  to allow for lazy
                     instantiation or what?
.:13:06:37:. <@mst> it does the caller introspection there IIRC
.:13:09:56:. <@mst> I've spent like a year thinking about how to do logging sanely
.:13:10:17:. <@mst> having it turn out to be this bloody trivial to implement amuses me
.:13:10:43:. <@frew> mst: I guess that's why thinking about it for a year is worth it :-)
.:13:12:01:. <@mst> there's a couple other things we'll want, I suspect
.:13:12:18:. <@mst> like a concept of depth and a category system separate from the logger
.:13:12:24:. <@mst> but those can be handled later atop this API
.:13:13:35:. <@frew> so like, logging from the model, logging from the controller, logging from
                     the DBIDS part of the model vs the DBIC part of the model ?
.:13:14:13:. <@mst> that sort of thing
.:13:14:20:. <@mst> how much of that we can delegate to the logger I dunno yet

