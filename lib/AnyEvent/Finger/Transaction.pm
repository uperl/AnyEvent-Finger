package AnyEvent::Finger;

use strict;
use warnings;
use v5.10;
use mop;

# ABSTRACT: Simple asynchronous finger transaction
# VERSION

=head1 DESCRIPTION

This class is a container for response and request objects
which is used when a finger request comes into 
L<AnyEvent::Finger::Server> server instance.  It also provides
information about the connection (the remote, local ports and
the remote client's address).

=head1 METHODS

=head2 $tx-E<gt>req

Returns the request object associated with the transaction
(an instance of L<AnyEvent::Finger::Request>).

=head2 $tx-E<gt>res

Returns the response object associated with the transaction
(an instance of L<AnyEvent::Finger::Response>).

=cut

class Transaction
{

  has $!res is ro;
  has $!req is ro;

=head2 $tx-E<gt>remote_port

Returns the remote TCP port being used to make the request.

=head2 $tx-E<gt>local_port

Returns the local TCP port being used to make the request.

=cut

  has $!remote_port is ro;
  has $!local_port is ro;

=head2 $tx-E<gt>remote_address

Returns the IP address from whence the finger request is coming from.

=cut

  has $!remote_address is ro;

}

1;
