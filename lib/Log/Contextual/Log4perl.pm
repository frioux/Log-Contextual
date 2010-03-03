# make wrapper for Log::Log4perl that fixes callstack:
#   < mst> sub debug { local $Log::Log4perl::caller_depth =
#          $Log::Log4perl::caller_depth + 3; shift->{l4p}->debug(@_) }
package Log::Contextual::Log4perl;

1;

__END__

=head1 NAME

Log::Contextual::Log4perl - wrapper to fix callstack for Log::Log4perl::Logger

=cut

