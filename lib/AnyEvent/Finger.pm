package AnyEvent::Finger;

use strict;
use warnings;
use v5.10;
use base qw( Exporter );

our @EXPORT_OK = qw( finger_client );

# ABSTRACT: Simple asyncronous finger
# VERSION

=head1 SYNOPSIS

client:

 use AnyEvent::Finger qw( finger_client );
 
 finger_client 'localhost', 'username', sub {
   my($lines) = @_;
   say "[response]";
   say join "\n", @$lines;
 };

=head1 FUNCTIONS

=head2 finger_client( $server, $request, $callback, \%options )

Send a finger request to the given server.  The callback will
be called when the response is complete.  The options hash may
be passed in as the optional forth argument to override any
default options (See L<AnyEvent::Finger::Client> for details).

=cut

sub finger_client
{
  my($server) = shift;
  require AnyEvent::Finger::Client;
  AnyEvent::Finger::Client
    ->new( hostname => $server )
    ->finger(@_);
}

1;
