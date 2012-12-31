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
    my($request, $response) = @_;
    if($request->listing_request)
    {
      $response->(['list of sers:', '', '- grimlock', undef]);
    }
    else
    {
      if($request->username eq 'grimlock')
      {
        $response->(['ME GRIMLOCK HAVE AN ACCOUNT ON THIS MACHINE', undef]);
      }
      else
      {
        $response->(['no such user', undef]);
      }
    }
  }
);

AnyEvent->condvar->recv;
