package AnyEvent::Finger::Response;

use strict;
use warnings;

# ABSTRACT: Simple asynchronous finger response
# VERSION

=head1 DESCRIPTION

This class provides an interface for constructing a response
from a finger server for L<AnyEvent::Finger::Server>.  See
the documentation on that class for more details.

=head1 METHODS

=head2 $response-E<gt>say( @lines )

Send the lines to the client.  Do not include new line characters (\r, 
\n or \r\n), these will be added by L<AnyEvent::Finger::Server>.

=cut

sub say
{
  shift->(\@_);
}

=head2 $response-E<gt>done

Close the connection with the client.  This signals that the response is
complete.  Do not forget to call this!

=cut

sub done
{
  shift->();
}

1;
