use strict;
use warnings;
use Test::More tests => 2;
use AnyEvent;
use AnyEvent::Finger qw( finger_server finger_client );

my $port = 8000+int(rand(1024));
diag "port $port";

eval { 
  use YAML ();
  finger_server sub {
    my($request, $callback) = @_;
    $callback->([
      "request = '$request'",
      undef,
    ]);
  }, { port => $port, hostname => '127.0.0.1' };
};
diag $@ if $@;

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
