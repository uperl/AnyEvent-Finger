package AnyEvent::Finger::Server;

use strict;
use warnings;
use v5.10;
use Carp qw( croak );
use AnyEvent;
use AnyEvent::Handle;
use AnyEvent::Socket qw( tcp_server );
use AnyEvent::Finger::Request;
use AnyEvent::Finger::Response;

# ABSTRACT: Simple asynchronous finger server
# VERSION

=head1 SYNOPSIS

 use AnyEvent::Finger::Server;
 my $server = AnyEvent::Finger::Server->new;
 
 my %users = (
   grimlock => "ME GRIMLOCK HAVE PLAN",
   optimus  => "Freedom is the right of all sentient beings.",
 );
 
 $server->start(
   my($request, $response) = @_;
   if($request->listing_request)
   {
     # respond if remote requests list of users
     $response->say('users:', keys %users);
     $response->done;
   }
   else
   {
     # respond if user exists
     if(defined $users{$request->username})
     {
       $response->say($users{$request->username});
       $response->done;
     }
     # respond if user does not exist
     else
     {
       $response->say('no such user');
       $response->done;
     }
   }
 );

=head1 DESCRIPTION

Provide a simple asynchronous finger server.

=head1 CONSTRUCTOR

The constructor takes the following optional arguments:

=over 4

=item *

hostname (default 127.0.0.1)

The hostname to connect to.

=item *

port (default 79)

The port to connect to.

=item *

on_error (carp error)

A callback subref to be called on error (either connection or transmission error).
Passes the error string as the first argument to the callback.

=back

=cut

sub new
{
  my $class = shift;
  my $args     = ref $_[0] eq 'HASH' ? (\%{$_[0]}) : ({@_});
  bless {
    hostname => $args->{hostname},  
    port     => $args->{port}     // 79,
    on_error => $args->{on_error} // sub { carp $_[0] },
  }, $class;
}

=head1 METHODS

=head2 $server-E<gt>start( $callback )

Start the finger server.  The callback will be called each time a
client connects.

 $callback->($request, $response_callback)

The first argument passed to the callback is the request object,
an instance of L<AnyEvent::Finger::Request>.

The second argument passed to the callback is the response object,
an instance of L<AnyEvent::Finger::Response>.  With this object
you can return a whole response at one time:

 $response->say(
   "this is the first line", 
   "this is the second line", 
   "there will be no forth line",
 );
 $response->done;

or you can send line one at a time as they become available (possibly
asynchronously).

 # $dbh is a DBI database handle
 my $sth = $dbh->prepare("select user_name from user_list");
 while(my $h = $sth->fetchrow_hashref)
 {
   $response_callback->say($h->{user_name});
 }
 $response_callback->done;

The server will unbind from its port and stop if the server
object falls out of scope, or if the C<stop> method (see below)
is called.
 
=cut

sub start
{
  my $self     = shift;
  my $callback = shift;
  my $args     = ref $_[0] eq 'HASH' ? (\%{$_[0]}) : ({@_});
  
  croak "already started" if $self->{guard};
  
  $args->{$_} //= $self->{$_}
    for qw( hostname port on_error );

  my $cb = sub {
    my ($fh, $host, $port) = @_;
    
    my $handle;
    $handle = AnyEvent::Handle->new(
      fh       => $fh,
      on_error => sub {
        my ($hdl, $fatal, $msg) = @_;
        $args->{on_error}->($msg);
        $_[0]->destroy;
      },
      on_eof   => sub {
        $handle->destroy;
      },
    );
    
    $handle->push_read( line => sub {
      my($handle, $line) = @_;
      $line =~ s/\015?\012//g;
      
      my $response = sub {
        my $lines = shift;
        $lines = [ $lines ] unless ref $lines eq 'ARRAY';
        foreach my $line (@$lines)
        {
          if(defined $line)
          {
            $handle->push_write($line . "\015\012");
          }
          else
          {
            $handle->destroy;
            return;
          }
        }
      };
      
      bless $response, 'AnyEvent::Finger::Response';
      
      $callback->(AnyEvent::Finger::Request->new($line), $response);
    });
  };
  
  if($args->{port} == 0)
  {
    my $done = AnyEvent->condvar;
    $self->{guard} = tcp_server $args->{hostname}, undef, $cb, sub {
      my($fh, $host, $port) = @_;
      $self->{bindport} = $port;
      $done->send;
    };
    $done->recv;
  }
  else
  {
    $self->{guard} = tcp_server $args->{hostname}, $args->{port}, $cb;
    $self->{bindport} = $self->{port};
  }
  
  $self;
}

=head2 $server-E<gt>bindport

The bind port.  If port is set to zero in the constructor or on
start, then an ephemeral port will be used, and you can get the
port number here.

=cut

sub bindport { shift->{bindport} }

=head2 $server-E<gt>stop

Stop the server and unbind to the port.

=cut

sub stop
{
  my($self) = @_;
  delete $self->{guard};
  delete $self->{bindport};
  $self;
}

1;
