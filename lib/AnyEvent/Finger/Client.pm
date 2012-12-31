package AnyEvent::Finger::Client;

use strict;
use warnings;
use v5.10;
use AnyEvent::Socket qw( tcp_connect );
use AnyEvent::Handle;
use Carp qw( carp );

# ABSTRACT: Simple asynchronous finger client
# VERSION

=head1 SYNOPSIS

 use AnyEvent;
 use AnyEvent::Finger::Client;
 
 my $done = AnyEvent->condvar;
 
 my $client = AnyEvent::Finger::Client->new;
 
 $client->finger('username', sub {
   my($lines) = @_;
   say "[response]";
   say join "\n", @$lines;
 }, on_error => sub {
   say STDERR shift;
 });

=head1 DESCRIPTION

Provide a simple asynchronous finger client.

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

timeout (default 60)

The connection timeout.

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
    hostname => $args->{hostname} // '127.0.0.1',  
    port     => $args->{port}     // 79,
    timeout  => $args->{timeout}  // 60,
    on_error => $args->{on_error} // sub { carp $_[0] },
  }, $class;
}

=head1 METHODS

=head2 $client-E<gt>finger($request, $callback, [ \%options ])

Connect to the finger server make the given request and call the given callback
when the response is complete.  The response will be passed to the callback as
an array reference of lines.  Each line will have the new line (\n or \r or \r\n)
removed.  Any of the arguments passed into the constructor as passed above
may be overridden specifying them in the options hash (third argument).

=cut

sub finger
{
  my $self     = shift;
  my $request  = shift // '';
  my $callback = shift // sub {};
  my $args     = ref $_[0] eq 'HASH' ? (\%{$_[0]}) : ({@_});
  
  $args->{$_} //= $self->{$_}
    for qw( hostname port timeout on_error );
  
  tcp_connect $args->{hostname}, $args->{port}, sub {
  
    my($fh) = @_;
    return $args->{on_error}->("unable to connect: $!") unless $fh;
    
    my @lines;
    
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
        $callback->(\@lines);
      },
    );
    
    if(ref $request && $request->isa('AnyEvent::Finger::Request'))
    { $request = $request->{raw} }
    $handle->push_write("$request\015\012");
    
    $handle->on_read(sub {
      $handle->push_read( line => sub {
        my($handle, $line) = @_;
        $line =~ s/\015?\012//g;
        push @lines, $line;
      });
    });
  
  }, sub { $args->{timeout} };
  
  $self;
}

1;
