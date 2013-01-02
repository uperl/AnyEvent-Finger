package AnyEvent::Finger::Transaction;

use strict;
use warnings;
use v5.10;
use overload '""' => sub { shift->as_string };

# ABSTRACT: Simple asynchronous finger transaction
# VERSION

=head1 METHODS

=head2 $tx-E<gt>req

Returns the request object associated with the transaction
(an instance of L<AnyEvent::Finger::Request>).

=head2 $tx-E<gt>res

Returns the response object associated with the transaction
(an instance of L<AnyEvent::Finger::Response>).

=cut

sub res { shift->{res} }
sub req { shift->{req} }

=head2 $tx-E<gt>remote_port

Returns the remote TCP port being used to make the request.

=head2 $tx-E<gt>local_port

Returns the local TCP port being used to make the request.

=cut

sub remote_port { shift->{remote_port} }
sub local_port { shift->{local_port} }

=head2 $tx-E<gt>remote_address

Returns the IP address from whence the finger request is coming from.

=cut

sub remote_address { shift->{remote_address} }

1;