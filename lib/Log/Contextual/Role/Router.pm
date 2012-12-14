package Log::Contextual::Role::Router;

use Moo::Role;

requires 'before_import';
requires 'after_import';
requires 'handle_log_request';

1;

__END__

=head1 NAME

Log::Contextual::Role::Router - Abstract interface between loggers and logging code blocks

=head1 SYNOPSIS

  package Custom::Logging::Router;
  
  use Moo;
  use Log::Contextual::SimpleLogger;
  
  with 'Log::Contextual::Role::Router';
  
  has logger => (is => 'lazy');
  
  sub _build_logger {
     return Log::Contextual::SimpleLogger->new({ levels_upto => 'debug' });
  }
  
  sub before_import {
     my ($self, $log_class, $importer, $spec) = @_;
     print STDERR "Package '$importer' will import '$log_class'\n";
  }

  sub after_import {
     my ($self, $log_class, $importer, $spec) = @_;
     print STDERR "Package '$importer' has imported '$log_class'\n";
  }

  sub handle_log_request {
    my ($self, $metadata, $log_code_block, @args) = @_;
    my $log_level_name = $metadata->{level};
    my $logger = $self->logger;
    my $is_active = $logger->can("is_$log_level_name");
    
    return unless defined $is_active && $logger->$is_active;
    my $log_message = $log_code_block->(@args);
    $logger->$log_level_name($log_message);
  }

  package Custom::Logging::Class;

  use Moo;

  extends 'Log::Contextual';

  #Almost certainly the router object should be a singleton
  sub router {
     our $Router ||= Custom::Logging::Router->new
  }

  package main;

  use strictures;
  use Custom::Logging::Class qw(:log);
  
  log_info { "Hello there" };

=head1 DESCRIPTION

Log::Contextual has three parts

=over 4

=item Export manager and logging method generator

These tasks are handled by the C<Log::Contextual> class.

=item Logger selection and invocation

The log methods generated and exported by Log::Contextual call a method
on a log router object which is responsible for invoking any loggers that should
get an opportunity to receive the log message. The C<Log::Contextual::Router>
class implements the set_logger() and with_logger() methods as well as uses the
arg_ prefixed methods to configure itself and provide the standard C<Log::Contextual>
logger selection API.

=item Log message formatting and output

The logger objects themselves accept or reject a log message at a certain log
level with a guard method per level. If the logger is going to accept the
log message the router is then responsible for executing the log message code
block and passing the generated message to the logging object's log method.

=back

=head1 METHODS

=over 4

=item before_import($self, $log_class, $importer, $spec)

=item after_import($self, $log_class, $importer, $spec)

These two required methods are called with identical arguments at two different places
during the import process. The before_import() method is invoked prior to the logging
methods being exported into the consuming packages namespace. The after_import() method
is called when the export is completed but before control returns to the package that
imported the class.

The arguments are as follows:

=over 4

=item $log_class

This is the package name of the subclass of Log::Contextual that has been imported. It can
also be 'Log::Contextual' itself. In the case of the synopsis the value in $log_class would be
'Custom::Logging::Class'.

=item $importer

This is the package name that is importing the logging class. In the case of the synopsis the
value would be 'main'.

=item $spec

This is the import specification that is being used when exporting methods to $importer. The
value is an unmodified C<Exporter::Declare::Specs> object.

=back

=item handle_log_request($self, $info, $generator, @args)

This method is called by C<Log::Contextual> when a log event happens. The arguments are as
follows:

=over 4

=item $info

This is the metadata describing the log event. The value is a hash reference with the following
keys:

=over 4

=item controller

This is the name of the Log::Contextual subclass (or 'Log::Contextual' itself) that created
the logging methods used to generate the log event.

=item package

This is the name of the package that the log event has happened inside of.

=item caller_level

This is an integer that contains the value to pass to caller() that will provide
information about the location the log event was created at.

=item level

This is the name of the log level associated with the log event.

=back

=item $generator

This is the message generating block associated with the log event passed as a subref. If
the logger accepts the log request the router should execute the generator to create
the log message and then pass the message as a string to the logger.

=item @args

This is the arguments provided to the log block passed through completely unmodified. When
invoking the generator method it will almost certainly be expecting these argument values
as well.

=back

=back

=head1 SEE ALSO

=over 4

=item C<Log::Contextual>

=back


