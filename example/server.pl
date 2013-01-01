#!/usr/bin/perl

use strict;
use warnings;
use v5.10;
use AnyEvent::Finger::Server;

# bind to 79 if root, otherwise use
# an unprivilaged port
my $port = ($> && $^O !~ /^(cygwin|MSWin32)$/) ? 8079 : 79;

say "listening to port $port";

my $server = AnyEvent::Finger::Server->new( port => $port );

$server->start(
  sub {
    my $tx = shift;
    if($tx->req->listing_request)
    {
      $tx->res->send_lines('list of sers:', '', '- grimlock');
    }
    else
    {
      if($tx->req->username eq 'grimlock')
      {
        $tx->res->('ME GRIMLOCK HAVE AN ACCOUNT ON THIS MACHINE');
      }
      else
      {
        $tx->res->('no such user');
      }
    }
    $tx->res->done;
  }
);

AnyEvent->condvar->recv;
