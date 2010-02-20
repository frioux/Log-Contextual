package VarLogger;

sub new { bless { var => undef }, __PACKAGE__ }
sub var { $_[0]->{var} }

sub debug { $_[0]->{var} = "d$_[1]" }
sub is_debug { 1 }

sub trace { $_[0]->{var} = "t$_[1]" }
sub is_trace { 1 }

sub error { $_[0]->{var} = "e$_[1]" }
sub is_error { 1 }

sub info { $_[0]->{var} = "i$_[1]" }
sub is_info { 1 }

sub fatal { $_[0]->{var} = "f$_[1]" }
sub is_fatal { 1 }

sub warn { $_[0]->{var} = "w$_[1]" }
sub is_warn { 1 }

1;
