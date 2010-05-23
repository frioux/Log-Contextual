package Log::Contextual;

use strict;
use warnings;

our $VERSION = '0.00202';

require Exporter;
use Data::Dumper::Concise;
use Scalar::Util 'blessed';

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
      my $val = $_[$idx];
      if ( defined $val && $val eq '-logger' ) {
         set_logger($_[$idx + 1]);
         splice @_, $idx, 2;
      } elsif ( defined $val && $val eq '-default_logger' ) {
         _set_default_logger_for(scalar caller, $_[$idx + 1]);
         splice @_, $idx, 2;
      }
   }
   $package->export_to_level(1, $package, @_);
}

our $Get_Logger;
our %Default_Logger;

sub _set_default_logger_for {
   my $logger = $_[1];
   if(ref $logger ne 'CODE') {
      die 'logger was not a CodeRef or a logger object.  Please try again.'
         unless blessed($logger);
      $logger = do { my $l = $logger; sub { $l } }
   }
   $Default_Logger{$_[0]} = $logger
}

sub _get_logger($) {
   my $package = shift;
   (
      $Get_Logger ||
      $Default_Logger{$package} ||
      die q( no logger set!  you can't try to log something without a logger! )
   )->($package);
}

sub set_logger {
   my $logger = $_[0];
   if(ref $logger ne 'CODE') {
      die 'logger was not a CodeRef or a logger object.  Please try again.'
         unless blessed($logger);
      $logger = do { my $l = $logger; sub { $l } }
   }

   warn 'set_logger (or -logger) called more than once!  This is a bad idea!'
      if $Get_Logger;
   $Get_Logger = $logger;
}

sub with_logger {
   my $logger = $_[0];
   if(ref $logger ne 'CODE') {
      die 'logger was not a CodeRef or a logger object.  Please try again.'
         unless blessed($logger);
      $logger = do { my $l = $logger; sub { $l } }
   }
   local $Get_Logger = $logger;
   $_[1]->();
}

sub _do_log {
   my $level  = shift;
   my $logger = shift;
   my $code   = shift;
   my @values = @_;

   local $Log::Log4perl::caller_depth = ($Log::Log4perl::caller_depth || 0 ) + 2;
   $logger->$level($code->(@_))
      if $logger->${\"is_$level"};
   @values
}

sub _do_logS {
   my $level  = shift;
   my $logger = shift;
   my $code   = shift;
   my $value  = shift;

   local $Log::Log4perl::caller_depth = ($Log::Log4perl::caller_depth || 0 ) + 2;
   $logger->$level($code->($value))
      if $logger->${\"is_$level"};
   $value
}

sub log_trace (&@) { _do_log( trace => _get_logger( caller ), shift @_, @_) }
sub log_debug (&@) { _do_log( debug => _get_logger( caller ), shift @_, @_) }
sub log_info  (&@) { _do_log( info  => _get_logger( caller ), shift @_, @_) }
sub log_warn  (&@) { _do_log( warn  => _get_logger( caller ), shift @_, @_) }
sub log_error (&@) { _do_log( error => _get_logger( caller ), shift @_, @_) }
sub log_fatal (&@) { _do_log( fatal => _get_logger( caller ), shift @_, @_) }

sub logS_trace (&$) { _do_logS( trace => _get_logger( caller ), $_[0], $_[1]) }
sub logS_debug (&$) { _do_logS( debug => _get_logger( caller ), $_[0], $_[1]) }
sub logS_info  (&$) { _do_logS( info  => _get_logger( caller ), $_[0], $_[1]) }
sub logS_warn  (&$) { _do_logS( warn  => _get_logger( caller ), $_[0], $_[1]) }
sub logS_error (&$) { _do_logS( error => _get_logger( caller ), $_[0], $_[1]) }
sub logS_fatal (&$) { _do_logS( fatal => _get_logger( caller ), $_[0], $_[1]) }


sub Dlog_trace (&@) {
  my $code = shift;
  local $_ = (@_?Data::Dumper::Concise::Dumper @_:'()');
  return _do_log( trace => _get_logger( caller ), $code, @_ );
}

sub Dlog_debug (&@) {
  my $code = shift;
  local $_ = (@_?Data::Dumper::Concise::Dumper @_:'()');
  return _do_log( debug => _get_logger( caller ), $code, @_ );
}

sub Dlog_info (&@) {
  my $code = shift;
  local $_ = (@_?Data::Dumper::Concise::Dumper @_:'()');
  return _do_log( info => _get_logger( caller ), $code, @_ );
}

sub Dlog_warn (&@) {
  my $code = shift;
  local $_ = (@_?Data::Dumper::Concise::Dumper @_:'()');
  return _do_log( warn => _get_logger( caller ), $code, @_ );
}

sub Dlog_error (&@) {
  my $code = shift;
  local $_ = (@_?Data::Dumper::Concise::Dumper @_:'()');
  return _do_log( error => _get_logger( caller ), $code, @_ );
}

sub Dlog_fatal (&@) {
  my $code = shift;
  local $_ = (@_?Data::Dumper::Concise::Dumper @_:'()');
  return _do_log( fatal => _get_logger( caller ), $code, @_ );
}


sub DlogS_trace (&$) {
  local $_ = Data::Dumper::Concise::Dumper $_[1];
  _do_logS( trace => _get_logger( caller ), $_[0], $_[1] )
}

sub DlogS_debug (&$) {
  local $_ = Data::Dumper::Concise::Dumper $_[1];
  _do_logS( debug => _get_logger( caller ), $_[0], $_[1] )
}

sub DlogS_info (&$) {
  local $_ = Data::Dumper::Concise::Dumper $_[1];
  _do_logS( info => _get_logger( caller ), $_[0], $_[1] )
}

sub DlogS_warn (&$) {
  local $_ = Data::Dumper::Concise::Dumper $_[1];
  _do_logS( warn => _get_logger( caller ), $_[0], $_[1] )
}

sub DlogS_error (&$) {
  local $_ = Data::Dumper::Concise::Dumper $_[1];
  _do_logS( error => _get_logger( caller ), $_[0], $_[1] )
}

sub DlogS_fatal (&$) {
  local $_ = Data::Dumper::Concise::Dumper $_[1];
  _do_logS( fatal => _get_logger( caller ), $_[0], $_[1] )
}

1;

__END__

=head1 NAME

Log::Contextual - Simple logging interface with a contextual log

=head1 SYNOPSIS

 use Log::Contextual qw( :log :dlog set_logger with_logger );
 use Log::Contextual::SimpleLogger;
 use Log::Log4perl ':easy';
 Log::Log4perl->easy_init($DEBUG);


 my $logger  = Log::Log4perl->get_logger;

 set_logger $logger;

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

 foo();

Beginning with version 1.008 L<Log::Dispatchouli> also works out of the box
with C<Log::Contextual>:

 use Log::Contextual qw( :log :dlog set_logger );
 use Log::Dispatchouli;
 my $ld = Log::Dispatchouli->new({
    ident     => 'slrtbrfst',
    to_stderr => 1,
    debug     => 1,
 });

 set_logger $ld;

 log_debug { 'program started' };

=head1 DESCRIPTION

This module is a simple interface to extensible logging.  It is bundled with a
really basic logger, L<Log::Contextual::SimpleLogger>, but in general you
should use a real logger instead of that.  For something more serious but not
overly complicated, try L<Log::Dispatchouli> (see L</SYNOPSIS> for example.)

=head1 OPTIONS

=head2 -logger

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

=head2 -default_logger

The C<-default_logger> import option is similar to the C<-logger> import option
except C<-default_logger> sets the the default logger for the current package.

Basically it sets the logger to be used if C<set_logger> is never called; so

 package My::Package;
 use Log::Contextual::SimpleLogger;
 use Log::Contextual qw( :log ),
   -default_logger => Log::Contextual::WarnLogger->new({
      env_prefix => 'MY_PACKAGE'
   });

If you are interested in using this package for a module you are putting on
CPAN we recommend L<Log::Contextual::WarnLogger> for your default logger.

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

Arguments: C<Ref|CodeRef $returning_logger>

C<set_logger> will just set the current logger to whatever you pass it.  It
expects a C<CodeRef>, but if you pass it something else it will wrap it in a
C<CodeRef> for you.  C<set_logger> is really meant only to be called from a
top-level script.  To avoid foot-shooting the function will warn if you call it
more than once.

=head2 with_logger

 my $logger = WarnLogger->new;
 with_logger $logger => sub {
    if (1 == 0) {
       log_fatal { 'Non Logical Universe Detected' };
    } else {
       log_info  { 'All is good' };
    }
 };

Arguments: C<Ref|CodeRef $returning_logger, CodeRef $to_execute>

C<with_logger> sets the logger for the scope of the C<CodeRef> C<$to_execute>.
As with L</set_logger>, C<with_logger> will wrap C<$returning_logger> with a
C<CodeRef> if needed.

=head2 log_$level

Import Tag: C<:log>

Arguments: C<CodeRef $returning_message, @args>

All of the following six functions work the same except that a different method
is called on the underlying C<$logger> object.  The basic pattern is:

 sub log_$level (&@) {
   if ($logger->is_$level) {
     $logger->$level(shift->(@_));
   }
   @_
 }

Note that the function returns it's arguments.  This can be used in a number of
ways, but often it's convenient just for partial inspection of passthrough data

 my @friends = log_trace {
   'friends list being generated, data from first friend: ' .
     Dumper($_[0]->TO_JSON)
 } generate_friend_list();

If you want complete inspection of passthrough data, take a look at the
L</Dlog_$level> functions.

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

=head2 logS_$level

Import Tag: C<:log>

Arguments: C<CodeRef $returning_message, Item $arg>

This is really just a special case of the L</log_$level> functions.  It forces
scalar context when that is what you need.  Other than that it works exactly
same:

 my $friend = logS_trace {
   'I only have one friend: ' .  Dumper($_[0]->TO_JSON)
 } friend();

See also: L</DlogS_$level>.

=head2 Dlog_$level

Import Tag: C<:dlog>

Arguments: C<CodeRef $returning_message, @args>

All of the following six functions work the same as their L</log_$level>
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

Import Tag: C<:dlog>

Arguments: C<CodeRef $returning_message, Item $arg>

Like L</logS_$level>, these functions are a special case of L</Dlog_$level>.
They only take a single scalar after the C<$returning_message> instead of
slurping up (and also setting C<wantarray>) all the C<@args>

 my $pals_rs = DlogS_debug { "pals resultset: $_" }
   $schema->resultset('Pals')->search({ perlers => 1 });

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

