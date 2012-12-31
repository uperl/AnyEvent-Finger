#!/usr/bin/perl

use strict;
use warnings;
use AnyEvent::Finger::Server;

# bind to 79 if root, otherwise use
# an unprivilaged port
my $port = $> ? 8079 : 79;

my $server = AnyEvent::Finger::Server->new( port => $port );

$server->start(
  sub {
    my($request, $response) = @_;
    if($request)
    {
      if($request eq 'grimlock')
      {
        $response->(['ME GRIMLOCK HAVE AN ACCOUNT ON THIS MACHINE', undef]);
      }
      else
      {
        $response->(['no such user', undef]);
      }
    }
    else
    {
      $response->(['list of sers:', '', '- grimlock', undef]);
    }
  }
);

AnyEvent->condvar->recv;
