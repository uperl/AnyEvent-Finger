package AnyEvent::Finger::Server;

use strict;
use warnings;
use v5.10;
use AnyEvent::Handle;
use AnyEvent::Socket qw( tcp_server );

# ABSTRACT: Simple asyncronous finger server
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
   if($request)
   {
     # respond if user exists
     if(defined $users{$request})
     {
       $response->([$users{$request}, undef]);
     }
     # respond if user does not exist
     else
     {
       $response->(['no such user', undef]);
     }
   }
   else
   {
     # respond if remote requests list of users
     $response->(['users:', keys %users, undef]);
   }
 );

=head1 DESCRIPTION

Provide a simple asyncronous finger server.

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

The first argument passed to the callback is the name of the user
requested by the client or empty string ('') if no specific user
is requested (usually this means the client is requesting the list
of users currently logged in).

 $response_callback->($list)

The second argument is a subref to be called when the response has
been determined.  The response callback should be passed a list of
lines (without line termination, ie. \n \r or \r\n).  The response
callback may be called multiple times or just once.  The correct
line endings will automatically be added to each line and returned
to the client.  When the entire response is complete the response
callback should be called with undef, or with undef as the last
element in the list.

This way you can return a whole response at one time

 $reponse_callback->([
   "this is the first line", 
   "this is the second line", 
   "there will be no forth line",
   undef,
 ]);

or you can send line one at a time as they become available.

 # $dbh is a DBI database handle
 my $sth = $dbh->prepare("select user_name from user_list");
 while(my $h = $sth->fetchrow_hashref)
 {
   $response_callback->([$h->{user_name}]);
 }
 $response_callback->(); # same as (undef) in this case

=cut

sub start
{
  my $self     = shift;
  my $callback = shift;
  my $args     = ref $_[0] eq 'HASH' ? (\%{$_[0]}) : ({@_});
  
  $args->{$_} //= $self->{$_}
    for qw( hostname port on_error );

  tcp_server $args->{hostname}, $args->{port}, sub {
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
      $callback->($line, sub {
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
      });
    });
  };
  
  $self;
}

1;
