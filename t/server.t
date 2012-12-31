use strict;
use warnings;
use Test::More tests => 3;
use AnyEvent::Finger::Client;
use AnyEvent::Finger::Server;

my $port = 8000+int(rand(1024));
diag "port $port";

my $server = eval { AnyEvent::Finger::Server->new( port => $port, hostname => '127.0.0.1' ) };
diag $@ if $@;
isa_ok $server, 'AnyEvent::Finger::Server';

eval { $server->start(
  sub {
    my($request, $callback) = @_;
    $callback->([
      "request = '$request'",
      undef
    ]);
  }
) };
diag $@ if $@;

my $client = AnyEvent::Finger::Client->new( port => $port, on_error => sub { say STDERR shift; exit 2 } );

do {
  my $done = AnyEvent->condvar;

  my $lines;
  $client->finger('', sub {
    ($lines) = shift;
    $done->send;
  });
  
  $done->recv;
  
  is $lines->[0], "request = ''", 'response is correct';
};

do {
  my $done = AnyEvent->condvar;

  my $lines;
  $client->finger('grimlock', sub {
    ($lines) = shift;
    $done->send;
  });
  
  $done->recv;
  
  is $lines->[0], "request = 'grimlock'", 'response is correct';
};