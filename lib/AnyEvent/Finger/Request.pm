package AnyEvent::Finger::Request;

use strict;
use warnings;
use v5.10;
use overload '""' => sub { shift->as_string };

# ABSTRACT: Simple asynchronous finger request
# VERSION

=head1 CONSTRUCTOR

 my $request = AnyEvent::Finger::Request->new("foo@localhost");

The constructor takes a string which is the raw finger request.

=cut

sub new
{
  bless { raw => "$_[1]" // '' }, $_[0];
}

=head1 ATTRIBUTES

=head2 $request-E<gt>verbose

True if request is asking for a verbose response.  False
if request is not asking for a verbose response.

=cut

sub verbose
{
  my($self) = @_;
  $self->{verbose} //= ($self->{raw} =~ /^\/W/ ? 1 : 0);
}

=head2 $request-E<gt>username

The username being requested.

=cut

sub username
{
  my($self) = @_;
  
  unless(defined $self->{username})
  {
    if($self->{raw} =~ /^(?:\/W\s*)?([^@]*)/)
    { $self->{username} = $1 }
  }
  
  $self->{username};
}

=head2 $request-E<gt>hostnames

Returns a list of hostnames (as an array ref) in the request.

=cut

sub hostnames
{
  my($self) = @_;
  $self->{hostnames} //= ($self->{raw} =~ /\@(.*)$/ ? [split '@', $1] : []);
}

=head2 $request-E<gt>as_string

Converts just the username and hostnames fields into a string.

=cut

sub as_string
{
  my($self) = @_;
  join('@', ($self->username, @{ $self->hostnames }));
}

=head2 $request-E<gt>listing_request

Return true if the request is for a listing of users.

=cut

sub listing_request { shift->username eq '' ? 1 : 0 }


=head2 $request-E<gt>forward_request

Return true if the request is to query another host.

=cut

sub forward_request { @{ shift->hostnames } > 0 ? 1 : 0}

1;