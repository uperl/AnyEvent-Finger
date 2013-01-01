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

1;
