package Hostname;
    
use strict;
use warnings;

sub new {
    my ($class, %p) = @_;
    return bless { hostname => _validate($p{hostname}) }, $class;
}

sub hostname {
    $_[0]->{hostname};
}

# Validate hostnames if desired.  Not enough time to implement validation but the
# assumption is that robust validation would be implemented.  Always returns true for now.
sub _validate {
    # Should explicitly copy invocant off the stack... doing this elswhere also.
    return $_[0];
}

1;
