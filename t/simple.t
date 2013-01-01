use strict;
use warnings;
use Test::More tests => 3;
use AnyEvent;
use AnyEvent::Finger qw( finger_server finger_client );

my $port = eval { 
  my $server = finger_server sub {
    my $tx = shift;
    my $req = $tx->req;
    $tx->res->([
      "request = '$req'",
      undef,
    ]);
  }, { port => 0, hostname => '127.0.0.1' };
  $server->bindport;
};
diag $@ if $@;

like $port, qr{^[123456789]\d*$}, "bindport = $port";

my $error = sub { say STDERR shift; exit 2 };

do {
  my $done = AnyEvent->condvar;

  my $lines;
  finger_client '127.0.0.1', '', sub {
    ($lines) = shift;
    $done->send;
  }, { port => $port, on_error => $error};
  
  $done->recv;
  
  is $lines->[0], "request = ''", 'response is correct';
};

do {
  my $done = AnyEvent->condvar;

  my $lines;
  finger_client '127.0.0.1', 'grimlock', sub {
    ($lines) = shift;
    $done->send;
  }, { port => $port, on_error => $error };
  
  $done->recv;
  
  is $lines->[0], "request = 'grimlock'", 'response is correct';
};
