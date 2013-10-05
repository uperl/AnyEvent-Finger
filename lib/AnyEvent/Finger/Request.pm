package AnyEvent::Finger;

use strict;
use warnings;
use v5.10;
use mop;

# ABSTRACT: Simple asynchronous finger request
# VERSION

=head1 SYNOPSIS

 my $request = AnyEvent::Finger::Request->new('foo@localhost');

=head1 DESCRIPTION

This class represents finger request.  It is passed into
L<AnyEvent::Finger::Server> when a finger request is made.
See the documentation on that class for more details.

=head1 CONSTRUCTOR

=head2 AnyEvent::Finger::Request->new( $address )

The constructor takes a string which is the raw finger request.

=cut

class Request
{

  has $!raw;
  
  method new($class: $raw)
  {
    $class->next::method( raw => $raw );
  }
  
  method _raw { $!raw }

=head1 ATTRIBUTES

=head2 $request-E<gt>verbose

True if request is asking for a verbose response.  False
if request is not asking for a verbose response.

=cut

  has $!verbose;

  method verbose
  {
    $!verbose //= ($!raw =~ /^\/W/ ? 1 : 0);
  }

=head2 $request-E<gt>username

The username being requested.

=cut

  has $!username;
  
  method username
  {
    unless(defined $!username)
    {
      if($!raw =~ /^(?:\/W\s*)?([^@]*)/)
      { $!username = $1 }
    }
  
    $!username;
  }

=head2 $request-E<gt>hostnames

Returns a list of hostnames (as an array ref) in the request.

=cut

  has $!hostnames;

  method hostnames
  {
    say $!raw;
    $!hostnames //= ($!raw =~ /\@(.*)$/ ? [split '@', $1] : []);
  }

=head2 $request-E<gt>as_string

Converts just the username and hostnames fields into a string.

=cut

  method as_string is overload(q[""])
  {
    join('@', ($self->username, @{ $self->hostnames }));
  }

=head2 $request-E<gt>listing_request

Return true if the request is for a listing of users.

=cut

  method listing_request { $self->username eq '' ? 1 : 0 }


=head2 $request-E<gt>forward_request

Return true if the request is to query another host.

=cut

  method forward_request { @{ $self->hostnames } > 0 ? 1 : 0}

}

1;
