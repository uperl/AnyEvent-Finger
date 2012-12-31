package AnyEvent::Finger;

use strict;
use warnings;
use v5.10;
use base qw( Exporter );

our @EXPORT_OK = qw( finger_client finger_server );

# ABSTRACT: Simple asynchronous finger client and server
# VERSION

=head1 SYNOPSIS

client:

 use AnyEvent::Finger qw( finger_client );
 
 finger_client 'localhost', 'username', sub {
   my($lines) = @_;
   say "[response]";
   say join "\n", @$lines;
 };

server:

 use AnyEvent::Finger qw( finger_server );
 
 my %users = (
   grimlock => 'ME GRIMLOCK HAVE ACCOUNT ON THIS MACHINE',
   optimus  => 'Freedom is the right of all sentient beings.',
 );
 
 finger_server sub {
   my($request, $response) = @_;
   if($request->listing_request)
   {
     # respond if remote requests list of users
     $response->say('users: ', keys %users);
   }
   else
   {
     # respond if user exists
     if(defined $users{$request->username})
     {
       $response->say($users{$request});
     }
     # respond if user does not exist
     else
     {
       $response->say('no such user');
     }
   }
   $response->done;
 };

=head1 FUNCTIONS

=head2 finger_client( $server, $request, $callback, [ \%options ] )

Send a finger request to the given server.  The callback will
be called when the response is complete.  The options hash may
be passed in as the optional forth argument to override any
default options (See L<AnyEvent::Finger::Client> for details).

=cut

sub finger_client
{
  my($hostname) = shift;
  require AnyEvent::Finger::Client;
  AnyEvent::Finger::Client
    ->new( hostname => $hostname )
    ->finger(@_);
}

=head2 finger_server( $callback, [ \%options ] )

Start listening to finger callbacks and call the given callback
for each request.  See L<AnyEvent::Finger::Server> for details
on the options and the callback.

=cut

sub finger_server
{
  require AnyEvent::Finger::Server;
  my $server = AnyEvent::Finger::Server
    ->new
    ->start(@_);
  # keep the server object in scope so that
  # we don't unbind from the port.  If you 
  # don't want this, then use the OO interface
  # for ::Server instead.
  state $keep = [];
  push @$keep, $server;
  return $server;
}

1;

=head1 SEE ALSO

L<AnyEvent::Finger::Client>,
L<AnyEvent::Finger::Server>

=cut
