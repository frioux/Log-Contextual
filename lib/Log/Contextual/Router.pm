package Log::Contextual::Router;

use Moo;
use Scalar::Util 'blessed';

with 'Log::Contextual::Role::Router';

sub before_import { }

sub after_import {
   my ($self, $controller, $importer, $spec) = @_;
   my $config = $spec->config;

   if (my $l = $controller->arg_logger($config->{logger})) {
      $self->set_logger($l)
   }

   if (my $l = $controller->arg_package_logger($config->{package_logger})) {
      $self->_set_package_logger_for($importer, $l)
   }

   if (my $l = $controller->arg_default_logger($config->{default_logger})) {
      $self->_set_default_logger_for($importer, $l)
   }
}

sub with_logger {
   my $logger = $_[1];
   if(ref $logger ne 'CODE') {
      die 'logger was not a CodeRef or a logger object.  Please try again.'
         unless blessed($logger);
      $logger = do { my $l = $logger; sub { $l } }
   }
   local $_[0]->{Get_Logger} = $logger;
   $_[2]->();
}

sub set_logger {
   my $logger = $_[1];
   if(ref $logger ne 'CODE') {
      die 'logger was not a CodeRef or a logger object.  Please try again.'
         unless blessed($logger);
      $logger = do { my $l = $logger; sub { $l } }
   }

   warn 'set_logger (or -logger) called more than once!  This is a bad idea!'
      if $_[0]->{Get_Logger};
   $_[0]->{Get_Logger} = $logger;

}

sub _set_default_logger_for {
   my $logger = $_[2];
   if(ref $logger ne 'CODE') {
      die 'logger was not a CodeRef or a logger object.  Please try again.'
         unless blessed($logger);
      $logger = do { my $l = $logger; sub { $l } }
   }
   $_[0]->{Default_Logger}->{$_[1]} = $logger
}

sub _set_package_logger_for {
   my $logger = $_[2];
   if(ref $logger ne 'CODE') {
      die 'logger was not a CodeRef or a logger object.  Please try again.'
         unless blessed($logger);
      $logger = do { my $l = $logger; sub { $l } }
   }
   $_[0]->{Package_Logger}->{$_[1]} = $logger
}

sub get_loggers {
   my ($self, $package, $level) = @_;
   my $logger = (
      $_[0]->{Package_Logger}->{$package} ||
      $_[0]->{Get_Logger} ||
      $_[0]->{Default_Logger}->{$package} ||
      die q( no logger set!  you can't try to log something without a logger! )
   );

   $logger = $logger->($package, { caller_level => 2 });

   return $logger if $logger->${\"is_$level"};
   return (); 
}

1; 

