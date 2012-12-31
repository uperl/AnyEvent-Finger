#!/usr/bin/perl

use strict;
use warnings;
use v5.10;
use AnyEvent;
use AnyEvent::Finger::Client;

my $done = AnyEvent->condvar;

# bind to 79 if root, otherwise use
# an unprivilaged port
my $port = $> ? 8079 : 79;

my $client = AnyEvent::Finger::Client->new( port => $port );

$client->finger(shift @ARGV, sub {
  my($lines) = @_;
  say "[response]";
  say join "\n", @$lines;
  $done->send;
}, on_error => sub {
  say STDERR shift;
  $done->send;
});

$done->recv;
