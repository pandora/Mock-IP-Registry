package Registry;

use strict;
use warnings;

use Carp;
use IPv4;
use Hostname;

use Data::Dumper;
use Scalar::Util 'refaddr';

# Depending on how inheritance is handled by the application use Class::C3 to
# achieve sane MRO i.e. prevent classes from appearing before their respective subclasses;

my $data      = {};  # Save the registry in here.. this is a process cache.
my $singleton = q{}; # We don't need more than one instance of the class to be available.

sub new {
    my $class = shift;
    do {
        $singleton = bless { 
            # Closures give us some degree of encapsulation. Performance has been compromised here; what is needed is
            # an index of hostnames or that hostnames be the actual key of the data hash.
            get => sub { local *__ANON__ = 'getter'; $data->{refaddr $_[0]}; },
            set => sub { local *__ANON__ = 'setter'; $data->{refaddr $_[0]} = {h => $_[0], a => $_[1]}; },
        }, $class;
    } unless $singleton;

    return $singleton;
}

sub addEntry {
    my ($self, %p) = @_;

    croak "Hostname and ipaddrlist not provided !"
        unless $p{hostname} && $p{ipaddrlist};

    my $entry    = $self->_getEntryByHostname($p{hostname});
    my $hostname = $entry ? $entry->{h} :
        Hostname->new(hostname => $p{hostname});

    my $ipaddress = $entry ? $entry->{a} : 
        IPv4->new(ipaddrlist => $p{ipaddrlist});

    # Each IP address may have only one hostname:
    foreach my $obj (values %{$data}) {
        next if $obj->{h}->hostname eq $p{hostname};
        foreach my $ip ( @{$p{ipaddrlist}} ) {
            croak "Duplicate IP: $ip detected for $p{hostname} !"
                if grep { $_ eq $ip } @{$obj->{a}->list};
        }
    }

    $ipaddress->set($p{ipaddrlist});

    # Ensure that each hostname has at least 1 IP address.
    croak "Each hostname must refer to one IP address at least: $p{hostname}"
        unless scalar @{$ipaddress->list};
    $self->{set}->($hostname, $ipaddress);
}

# Modify an IP address:
sub replaceEntry {
    my ($self, %p) = @_;

    croak "Hostname and ipaddrlist not provided !"
        unless $p{hostname} && $p{ipaddrlist};

    $self->_deleteEntryByHostname($p{hostname});
    $self->addEntry(%p);
}

# List all hostnames:
sub listHostnames {
    my @list = ();
    foreach my $obj (values %{$data}) {
        push @list, $obj->{h}->hostname;
    }
    @list = sort @list;
    return \@list;
}

# List all IP addresses:
sub listIPs {
    my %list = ();
    foreach my $obj (values %{$data}) {
        foreach my $ip (@{$obj->{a}->list}) {
            $list{$ip}++;
        }
    }
    return [sort keys %list];
}

sub getIpByHost {
    my ($self, $hostname) = @_;
    
    my $entry = $self->_getEntryByHostname($hostname);
    return $entry ? $entry->{a}->list : q{};
}

# Get hostname for a particular IP address:
sub getHostByIP {
    my ($self, $ip) = @_;
    foreach my $obj (values %{$data}) {
        return $obj->{h}->hostname if $obj->{a}->exists($ip);    
    }
    return;
}

# Persist registry to disk- would ideally serialize to YAML or save into relational DB.
# Storing serialized objects allows one to store the data anywhere easily i.e. Amazon SDB, relational DB etc.
sub save {
    my ($self, $file) = @_;
    open my $fh, ">$file" or die "Unable to open: $!";
    print $fh Data::Dumper->Dump([$data], ["HashRef"]);
    close $fh;

    return $data;
}

# Load registry from disk-> deserialising using eval is NOT safe !!!
# YAML::Loader is far safer !
sub load {
    my ($self, $file) = @_;
    my $hash;
    $hash = eval { do $file };
    $data = $hash;
    return $data;
}

sub _getEntryByHostname {
    my ($self, $hostname) = @_;
    foreach my $obj (values %{$data}) {
        return $obj if $obj->{h}->hostname eq $hostname;
    }
    return;
}

sub _deleteEntryByHostname {
    my ($self, $hostname) = @_;
    foreach my $key (keys %{$data}) {
        delete $data->{$key} if $data->{$key}->{h}->hostname eq $hostname;
    }
    return;
}

1;
