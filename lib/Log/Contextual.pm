package Log::Contextual;

use strict;
use warnings;

our $VERSION = '0.004202';

my @levels = qw(debug trace warn info error fatal);

use Exporter::Declare;
use Exporter::Declare::Export::Generator;
use Data::Dumper::Concise;
use Scalar::Util 'blessed';

my @dlog = ((map "Dlog_$_", @levels), (map "DlogS_$_", @levels));

my @log = ((map "log_$_", @levels), (map "logS_$_", @levels));

eval {
   require Log::Log4perl;
   die if $Log::Log4perl::VERSION < 1.29;
   Log::Log4perl->wrapper_register(__PACKAGE__)
};

# ____ is because tags must have at least one export and we don't want to
# export anything but the levels selected
sub ____ {}

exports ('____',
   @dlog, @log,
   qw( set_logger with_logger )
);

export_tag dlog => ('____');
export_tag log  => ('____');
import_arguments qw(logger package_logger default_logger);

sub arg_router {
   return $_[1] if defined $_[1];
   our $Router_Instance ||= do {
      require Log::Contextual::Router;
      Log::Contextual::Router->new
   }
}

sub arg_logger { $_[1] }
sub arg_levels { $_[1] || [qw(debug trace warn info error fatal)] }
sub arg_package_logger { $_[1] }
sub arg_default_logger { $_[1] }

sub before_import {
   my ($class, $importer, $spec) = @_;
   my $router = $class->arg_router;

   die 'Log::Contextual does not have a default import list'
      if $spec->config->{default};

   $router->before_import(@_);

   my @levels = @{$class->arg_levels($spec->config->{levels})};
   for my $level (@levels) {
      if ($spec->config->{log}) {
         $spec->add_export("&log_$level", sub (&@) {
            my ($code, @args) = @_;
            $router->handle_log_request({
               package => scalar(caller),
               caller_level => 1,
               level => $level,
            }, $code, @args);
            return @args;
         });
         $spec->add_export("&logS_$level", sub (&@) {
            my ($code, @args) = @_;
            $router->handle_log_request({
               package => scalar(caller),
               caller_level => 1,
               level => $level,
            }, $code, @args);
            return $args[0];
         });
      }
      if ($spec->config->{dlog}) {
         $spec->add_export("&Dlog_$level", sub (&@) {
            my ($code, @args) = @_;
            my $wrapped = sub {
               local $_ = (@_?Data::Dumper::Concise::Dumper @_:'()');
               &$code;
            };
            $router->handle_log_request({
               package => scalar(caller),
               caller_level => 1,
               level => $level,
            }, $wrapped, @args);
            return @args;
         });
         $spec->add_export("&DlogS_$level", sub (&$) {
            my ($code, $ref) = @_;
            my $wrapped = sub {
               local $_ = Data::Dumper::Concise::Dumper($_[0]);
               &$code;
            };
            $router->handle_log_request({
               package => scalar(caller),
               caller_level => 1,
               level => $level,
            }, $wrapped, $ref);
            return $ref;
         });
      }
   }
}

sub after_import { return arg_router()->after_import(@_) }

sub set_logger {
   my $router = arg_router();

   die ref($router) . " does not support set_logger()"
      unless $router->does('Log::Contextual::Role::Router::SetLogger');

   return $router->set_logger(@_);
}

sub with_logger {
   my $router = arg_router();

   die ref($router) . " does not support with_logger()"
      unless $router->does('Log::Contextual::Role::Router::WithLogger');

   return $router->with_logger(@_);
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

   my $minilogger = Log::Contextual::SimpleLogger->new({
     levels => [qw( trace debug )]
   });

   with_logger $minilogger => sub {
     log_trace { 'foo entered' };
     my ($foo, $bar) = Dlog_trace { "params for foo: $_" } @_;
     # ...
     log_trace { 'foo left' };
   };
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

Major benefits:

=over 2

=item * Efficient

The logging functions take blocks, so if a log level is disabled, the
block will not run:

 # the following won't run if debug is off
 log_debug { "the new count in the database is " . $rs->count };

Similarly, the C<D> prefixed methods only C<Dumper> the input if the level is
enabled.

=item * Handy

The logging functions return their arguments, so you can stick them in
the middle of expressions:

 for (log_debug { "downloading:\n" . join qq(\n), @_ } @urls) { ... }

=item * Generic

C<Log::Contextual> is an interface for all major loggers.  If you log through
C<Log::Contextual> you will be able to swap underlying loggers later.

=item * Powerful

C<Log::Contextual> chooses which logger to use based on L<< user defined C<CodeRef>s|/LOGGER CODEREF >>.
Normally you don't need to know this, but you can take advantage of it when you
need to later

=item * Scalable

If you just want to add logging to your extremely basic application, start with
L<Log::Contextual::SimpleLogger> and then as your needs grow you can switch to
L<Log::Dispatchouli> or L<Log::Dispatch> or L<Log::Log4perl> or whatever else.

=back

This module is a simple interface to extensible logging.  It exists to
abstract your logging interface so that logging is as painless as possible,
while still allowing you to switch from one logger to another.

It is bundled with a really basic logger, L<Log::Contextual::SimpleLogger>,
but in general you should use a real logger instead of that.  For something
more serious but not overly complicated, try L<Log::Dispatchouli> (see
L</SYNOPSIS> for example.)

=head1 A WORK IN PROGRESS

This module is certainly not complete, but we will not break the interface
lightly, so I would say it's safe to use in production code.  The main result
from that at this point is that doing:

 use Log::Contextual;

will die as we do not yet know what the defaults should be.  If it turns out
that nearly everyone uses the C<:log> tag and C<:dlog> is really rare, we'll
probably make C<:log> the default.  But only time and usage will tell.

=head1 IMPORT OPTIONS

See L</SETTING DEFAULT IMPORT OPTIONS> for information on setting these project
wide.

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

=head2 -levels

The C<-levels> import option allows you to define exactly which levels your
logger supports.  So the default,
C<< [qw(debug trace warn info error fatal)] >>, works great for
L<Log::Log4perl>, but it doesn't support the levels for L<Log::Dispatch>.  But
supporting those levels is as easy as doing

 use Log::Contextual
   -levels => [qw( debug info notice warning error critical alert emergency )];

=head2 -package_logger

The C<-package_logger> import option is similar to the C<-logger> import option
except C<-package_logger> sets the the logger for the current package.

Unlike L</-default_logger>, C<-package_logger> cannot be overridden with
L</set_logger>.

 package My::Package;
 use Log::Contextual::SimpleLogger;
 use Log::Contextual qw( :log ),
   -package_logger => Log::Contextual::WarnLogger->new({
      env_prefix => 'MY_PACKAGE'
   });

If you are interested in using this package for a module you are putting on
CPAN we recommend L<Log::Contextual::WarnLogger> for your package logger.

=head2 -default_logger

The C<-default_logger> import option is similar to the C<-logger> import option
except C<-default_logger> sets the the B<default> logger for the current package.

Basically it sets the logger to be used if C<set_logger> is never called; so

 package My::Package;
 use Log::Contextual::SimpleLogger;
 use Log::Contextual qw( :log ),
   -default_logger => Log::Contextual::WarnLogger->new({
      env_prefix => 'MY_PACKAGE'
   });

=head1 SETTING DEFAULT IMPORT OPTIONS

Eventually you will get tired of writing the following in every single one of
your packages:

 use Log::Log4perl;
 use Log::Log4perl ':easy';
 BEGIN { Log::Log4perl->easy_init($DEBUG) }

 use Log::Contextual -logger => Log::Log4perl->get_logger;

You can set any of the import options for your whole project if you define your
own C<Log::Contextual> subclass as follows:

 package MyApp::Log::Contextual;

 use base 'Log::Contextual';

 use Log::Log4perl ':easy';
 Log::Log4perl->easy_init($DEBUG)

 sub arg_default_logger { $_[1] || Log::Log4perl->get_logger }
 sub arg_levels { [qw(debug trace warn info error fatal custom_level)] }

 # or maybe instead of default_logger
 sub arg_package_logger { $_[1] }

 # and almost definitely not this, which is only here for completeness
 sub arg_logger { $_[1] }

Note the C<< $_[1] || >> in C<arg_default_logger>.  All of these methods are
passed the values passed in from the arguments to the subclass, so you can
either throw them away, honor them, die on usage, or whatever.  To be clear,
if you define your subclass, and someone uses it as follows:

 use MyApp::Log::Contextual -default_logger => $foo,
                            -levels => [qw(bar baz biff)];

Your C<arg_default_logger> method will get C<$foo> and your C<arg_levels>
will get C<[qw(bar baz biff)]>;

=head1 FUNCTIONS

=head2 set_logger

 my $logger = WarnLogger->new;
 set_logger $logger;

Arguments: L</LOGGER CODEREF>

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

Arguments: L</LOGGER CODEREF>, C<CodeRef $to_execute>

C<with_logger> sets the logger for the scope of the C<CodeRef> C<$to_execute>.
As with L</set_logger>, C<with_logger> will wrap C<$returning_logger> with a
C<CodeRef> if needed.

=head2 log_$level

Import Tag: C<:log>

Arguments: C<CodeRef $returning_message, @args>

C<log_$level> functions all work the same except that a different method
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

Which functions are exported depends on what was passed to L</-levels>.  The
default (no C<-levels> option passed) would export:

=over 2

=item log_trace

=item log_debug

=item log_info

=item log_warn

=item log_error

=item log_fatal

=back

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

Which functions are exported depends on what was passed to L</-levels>.  The
default (no C<-levels> option passed) would export:

=over 2

=item Dlog_trace

=item Dlog_debug

=item Dlog_info

=item Dlog_warn

=item Dlog_error

=item Dlog_fatal

=back

=head2 DlogS_$level

Import Tag: C<:dlog>

Arguments: C<CodeRef $returning_message, Item $arg>

Like L</logS_$level>, these functions are a special case of L</Dlog_$level>.
They only take a single scalar after the C<$returning_message> instead of
slurping up (and also setting C<wantarray>) all the C<@args>

 my $pals_rs = DlogS_debug { "pals resultset: $_" }
   $schema->resultset('Pals')->search({ perlers => 1 });

=head1 LOGGER CODEREF

Anywhere a logger object can be passed, a coderef is accepted.  This is so
that the user can use different logger objects based on runtime information.
The logger coderef is passed the package of the caller the caller level the
coderef needs to use if it wants more caller information.  The latter is in
a hashref to allow for more options in the future.

Here is a basic example of a logger that exploits C<caller> to reproduce the
output of C<warn> with a logger:

 my @caller_info;
 my $var_log = Log::Contextual::SimpleLogger->new({
    levels  => [qw(trace debug info warn error fatal)],
    coderef => sub { chomp($_[0]); warn "$_[0] at $caller_info[1] line $caller_info[2].\n" }
 });
 my $warn_faker = sub {
    my ($package, $args) = @_;
    @caller_info = caller($args->{caller_level});
    $var_log
 };
 set_logger($warn_faker);
 log_debug { 'test' };

The following is an example that uses the information passed to the logger
coderef.  It sets the global logger to C<$l3>, the logger for the C<A1>
package to C<$l1>, except the C<lol> method in C<A1> which uses the C<$l2>
logger and lastly the logger for the C<A2> package to C<$l2>.

Note that it increases the caller level as it dispatches based on where
the caller of the log function, not the log function itself.

 my $complex_dispatcher = do {

    my $l1 = ...;
    my $l2 = ...;
    my $l3 = ...;

    my %registry = (
       -logger => $l3,
       A1 => {
          -logger => $l1,
          lol     => $l2,
       },
       A2 => { -logger => $l2 },
    );

    sub {
       my ( $package, $info ) = @_;

       my $logger = $registry{'-logger'};
       if (my $r = $registry{$package}) {
          $logger = $r->{'-logger'} if $r->{'-logger'};
          my (undef, undef, undef, $sub) = caller($info->{caller_level} + 1);
          $sub =~ s/^\Q$package\E:://g;
          $logger = $r->{$sub} if $r->{$sub};
       }
       return $logger;
    }
 };

 set_logger $complex_dispatcher;

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

Copyright (c) 2012 the Log::Contextual L</AUTHOR> and L</DESIGNER> as listed
above.

=head1 LICENSE

This library is free software and may be distributed under the same terms as
Perl 5 itself.

=cut

