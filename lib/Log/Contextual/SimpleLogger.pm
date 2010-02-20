package Log::Contextual::SimpleLogger;

use strict;
use warnings;

{
  for my $name (qw[ trace debug info warn error fatal ]) {

    no strict 'refs';

    *{$name} = sub {
      my $self = shift;

      $self->_log( $name, @_ )
        if ($self->{$name});
    };

    *{"is_$name"} = sub {
      my $self = shift;
      return $self->{$name};
    };
  }
}

sub new {
  my ($class, $args) = @_;
  my $self = bless {}, $class;

  $self->{$_} = 1 for @{$args->{levels}};
  $self->{coderef} = $args->{coderef} || sub { print STDERR @_};
  return $self;
}

sub _log {
  my $self    = shift;
  my $level   = shift;
  my $message = join( "\n", @_ );
  $message .= "\n" unless $message =~ /\n$/;
  $self->{coderef}->(sprintf( "[%s] %s", $level, $message ));
}

1;

