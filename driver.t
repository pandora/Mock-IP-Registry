use lib './';

use Test::More 'no_plan';

use Registry;
use Data::Dumper;

my $registry = Registry->new;
$registry->addEntry(hostname => 'www.example.com', ipaddrlist => [qw/10.1.1.1 10.1.2.1 10.1.3.1/]);
$registry->addEntry(hostname => 'www.example.com', ipaddrlist => '10.1.4.1');
is_deeply(
    $registry->getIpByHost('www.example.com'),
    [sort qw/10.1.1.1 10.1.2.1 10.1.3.1 10.1.4.1/],
);

$registry->addEntry(hostname => 'www.joesoap.com', ipaddrlist => [qw/101.1.1.1 101.1.2.1 101.1.3.1/]);
is('www.joesoap.com', $registry->getHostByIP('101.1.2.1'));

# This would fail if we used a duplicate IP address.
$registry->addEntry(hostname => 'www.joesoaporg.org', ipaddrlist => [qw/101.1.1.21/]);
# This fails because 101.1.2.1 has already been used !
#$registry->addEntry(hostname => 'www.joesoaporg.org', ipaddrlist => [qw/101.1.2.1/]);

# This will fail with an error as each hostname must refer to one IP address at least.
#$registry->addEntry(hostname => 'www.joesoaporg2.org', ipaddrlist => []);

$registry->replaceEntry(hostname => 'www.joesoap.com', ipaddrlist => [qw/101.1.1.1 101.1.2.1/]);
is_deeply(
    $registry->getIpByHost('www.joesoap.com'),
    [sort qw/101.1.1.1 101.1.2.1/],
);

is_deeply(
    $registry->listHostnames,
    [sort qw/www.example.com www.joesoap.com www.joesoaporg.org/]
);

is_deeply(
    $registry->listIPs,
    [sort qw/10.1.1.1 10.1.2.1 10.1.3.1 10.1.4.1 101.1.1.1 101.1.2.1 101.1.1.21/]
);

my $presave  = $registry->save("/tmp/obj.txt");
my $postsave = $registry->load("/tmp/obj.txt");
is_deeply(
    $presave,
    $postsave    
);
