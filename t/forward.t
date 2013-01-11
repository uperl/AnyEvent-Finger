use strict;
use warnings;
use Test::More tests => 5;
use AnyEvent::Finger::Client;
use AnyEvent::Finger::Server;

my $server1 = AnyEvent::Finger::Server->new(
  port         => 0,
  hostname     => '127.0.0.1',
  forward_deny => 1,
);
$server1->start(sub {
  my $tx = shift;
  $tx->res->say('server1');
  $tx->res->done;
});

like $server1->bindport, qr{^[1-9]\d*$}, "server1->bindport = " . $server1->bindport;

my $client1 = AnyEvent::Finger::Client->new(
  port     => $server1->bindport,
  on_error => sub { say STDERR shift; exit 2 },
);

my $server2 = AnyEvent::Finger::Server->new(
  port     => 0,
  hostname => '127.0.0.1',
  forward  => $client1,
);
$server2->start(sub {
  my $tx = shift;
  $tx->res->say('server2');
  $tx->res->done;
});

like $server2->bindport, qr{^[1-9]\d*$}, "server2->bindport = " . $server2->bindport;

my $client2 = AnyEvent::Finger::Client->new(
  port     => $server2->bindport,
  on_error => sub { say STDERR shift; exit 2 },
);

do {
  my $done = AnyEvent->condvar;

  my $lines;
  $client2->finger('', sub {
    ($lines) = shift;
    $done->send;
  });
  
  $done->recv;
  
  is $lines->[0], 'server2', 'lines[0] == server2';
};

do {
  my $done = AnyEvent->condvar;

  my $lines;
  $client2->finger('@127.0.0.1', sub {
    ($lines) = shift;
    $done->send;
  });
  
  $done->recv;
  
  is $lines->[0], 'server1', 'lines[0] == server2';
};

do {
  my $done = AnyEvent->condvar;

  my $lines;
  $client2->finger('@127.0.0.1@127.0.0.1', sub {
    ($lines) = shift;
    $done->send;
  });
  
  $done->recv;
  
  is $lines->[0], 'finger forwarding service denied', 'lines[0] == finger forwarding service denied';
};
