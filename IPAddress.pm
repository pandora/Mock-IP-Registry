package IPAddress;

# Use a generic IPAddress class as we could be dealing with either 
# IPv4 or IPv6 addresses.

use Carp;
use Scalar::Util 'reftype';

use strict;
use warnings;

sub new {
    my ($class, %p) = @_;
    my %iplist = map { $_ => 1 } @{ $p{ipaddrlist} };
    return bless {
        ipaddrlist => {%iplist} || {},  # Use a hash instead of an array to make
                                        # reverse lookups faster.
    }, $class;
}

sub set {
    my ($self, $iplist) = @_;
    $iplist = [$iplist] unless reftype($iplist); # Interface supports scalars as well as lists
    foreach my $ipaddr ( @{$iplist} ) {
        croak "Invalid IP address: $ipaddr" 
            unless $self->isValidIP($ipaddr); # isValidIP should exist in subclass.

        $self->{ipaddrlist}->{$ipaddr} = 1;
    }
}

sub isValidIP {
    croak "isValidIP should be overridden !!";
}

sub list {
    my @list = sort keys %{$_[0]->{ipaddrlist}};
    return \@list;
}

sub exists {
    return $_[0]->{ipaddrlist}->{$_[1]} ? 1 : 0;
}

1;
