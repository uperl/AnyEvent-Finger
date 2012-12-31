#!/usr/bin/perl

use strict;
use warnings;
use v5.10;
use AnyEvent;
use AnyEvent::Finger::Client;

my $done = AnyEvent->condvar;

my $client = AnyEvent::Finger::Client->new;

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
