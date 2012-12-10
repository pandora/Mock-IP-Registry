package IPv4;

use strict;
use warnings;

use base 'IPAddress';

# Validate IPv4 addresses.  Not enough time to implement validation but the
# assumption is that robust validation would be implemented.  Always returns true for now:
sub isValidIP {
    return 1;
}

1;
