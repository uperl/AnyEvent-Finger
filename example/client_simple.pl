#!/usr/bin/perl

use strict;
use warnings;
use v5.10;
use AnyEvent;
use AnyEvent::Finger qw( finger_client );

my $done = AnyEvent->condvar;

finger_client 'localhost', shift @ARGV, sub {
  my($lines) = @_;
  say "[response]";
  say join "\n", @$lines;
  $done->send;
}, on_error => sub {
  say STDERR shift;
  $done->send;
};

$done->recv;
