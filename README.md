# AnyEvent::Finger ![static](https://github.com/uperl/AnyEvent-Finger/workflows/static/badge.svg) ![linux](https://github.com/uperl/AnyEvent-Finger/workflows/linux/badge.svg)

Simple asynchronous finger client and server

# SYNOPSIS

client:

```perl
use AnyEvent::Finger qw( finger_client );

finger_client 'localhost', 'username', sub {
  my($lines) = @_;
  print "[response]\n";
  print join "\n", @$lines;
};
```

server:

```perl
use AnyEvent::Finger qw( finger_server );

my %users = (
  grimlock => 'ME GRIMLOCK HAVE ACCOUNT ON THIS MACHINE',
  optimus  => 'Freedom is the right of all sentient beings.',
);

finger_server sub {
  my $tx = shift; # isa AnyEvent::Finger::Transaction
  if($tx->req->listing_request)
  {
    # respond if remote requests list of users
    $tx->res->say('users: ', keys %users);
  }
  else
  {
    # respond if user exists
    if(defined $users{$tx->req->username})
    {
      $tx->res->say($users{$request});
    }
    # respond if user does not exist
    else
    {
      $tx->res->say('no such user');
    }
  }
  # required! done generating the reply,
  # close the connection with the client.
  $tx->res->done;
};
```

# DESCRIPTION

This distribution provides an asynchronous finger server and
client which can be used by any event loop supported by
[AnyEvent](https://metacpan.org/pod/AnyEvent).  This specific module provides a simple procedural
interface to client and server classes also in this distribution.

# FUNCTIONS

## finger\_client

```
finger_client( $server, $request, $callback, [ \%options ] )
```

Send a finger request to the given server.  The callback will
be called when the response is complete.  The options hash may
be passed in as the optional forth argument to override any
default options (See [AnyEvent::Finger::Client](https://metacpan.org/pod/AnyEvent::Finger::Client) for details).

## finger\_server

```perl
my $server = finger_server $callback, \%options;
```

Start listening to finger callbacks and call the given callback
for each request.  See [AnyEvent::Finger::Server](https://metacpan.org/pod/AnyEvent::Finger::Server) for details
on the options and the callback.

# CAVEATS

Finger is an oldish protocol and almost nobody uses it anymore.

Most finger clients do not have a way to configure an alternate port.
Binding to the default port 79 on Unix usually requires root.  Running
[AnyEvent::Finger::Server](https://metacpan.org/pod/AnyEvent::Finger::Server) as root is not recommended.

Under Linux you can use `iptables` to forward requests to port 79 to
an unprivileged port.  I was able to use this incantation to forward port 79
to port 8079:

```
# iptables -t nat -A PREROUTING -p tcp --dport 79 -j REDIRECT --to-port 8079
# iptables -t nat -I OUTPUT -p tcp -d 127.0.0.1 --dport 79 -j REDIRECT --to-port 8079
```

The first rule is sufficient for external clients, the second rule was required
for clients connecting via the loopback interface (localhost).

# SEE ALSO

- [RFC1288](http://tools.ietf.org/html/rfc1288),
- [AnyEvent::Finger::Client](https://metacpan.org/pod/AnyEvent::Finger::Client),
- [AnyEvent::Finger::Server](https://metacpan.org/pod/AnyEvent::Finger::Server)
- [AnyEvent](https://metacpan.org/pod/AnyEvent)

    Generic non-blocking event loop used by [AnyEvent::Finger](https://metacpan.org/pod/AnyEvent::Finger)

- [Net::Finger](https://metacpan.org/pod/Net::Finger)

    Blocking implementation of a finger client

- [Net::Finger::Server](https://metacpan.org/pod/Net::Finger::Server)

    Blocking implementation of a finger server

- [PlugAuth::Plugin::Finger](https://metacpan.org/pod/PlugAuth::Plugin::Finger)

    PlugAuth plugin that allows querying a PlugAuth server
    via the finger protocol.  Uses this module for its
    implementation.

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2012-2022 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
