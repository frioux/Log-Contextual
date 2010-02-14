package VarLogger;

sub new { bless { var => undef }, __PACKAGE__ }
sub debug { $_[0]->{var} = $_[1] }
sub var { $_[0]->{var} }
sub is_debug { 1 }

1;
