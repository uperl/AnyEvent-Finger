use strict;
use warnings;
use Test::More tests => 65;
use AnyEvent::Finger::Request;

do {

  my $raw = 'grimlock';
  is $raw, $raw, "[$raw]";
  my $request = eval { AnyEvent::Finger::Request->new($raw) };
  diag $@ if $@;
  isa_ok $request, 'AnyEvent::Finger::Request';
  
  is $request->verbose,  0,          'verbose = 0';
  is $request->username, 'grimlock', 'user = grimlock';
  is "$request",         'grimlock', 'raw = grimlock';
  
  is $request->listing_request, 0, 'listing_request = 0';
  is $request->forward_request, 0, 'forward_request = 0';
  
  is_deeply $request->hostnames, [], 'hostnames = []';

};

do {

  my $raw = '/W grimlock';
  is $raw, $raw, "[$raw]";
  my $request = eval { AnyEvent::Finger::Request->new($raw) };
  diag $@ if $@;
  isa_ok $request, 'AnyEvent::Finger::Request';
  
  is $request->verbose,  1,             'verbose = 1';
  is $request->username, 'grimlock',    'user = grimlock';
  is "$request",         'grimlock', 'raw = grimlock';

  is $request->listing_request, 0, 'listing_request = 0';
  is $request->forward_request, 0, 'forward_request = 0';
  
  is_deeply $request->hostnames, [], 'hostnames = []';

};

do {

  my $raw = 'grimlock@localhost';
  is $raw, $raw, "[$raw]";
  my $request = eval { AnyEvent::Finger::Request->new($raw) };
  diag $@ if $@;
  isa_ok $request, 'AnyEvent::Finger::Request';
  
  is $request->verbose,  0,                    'verbose = 0';
  is $request->username, 'grimlock',           'user = grimlock';
  is "$request",         'grimlock@localhost', 'raw = grimlock@localhost';
  
  is $request->listing_request, 0, 'listing_request = 0';
  is $request->forward_request, 1, 'forward_request = 1';
  
  is_deeply $request->hostnames, ['localhost'], 'hostnames = [localhost]';

};

do {

  my $raw = '/W grimlock@localhost';
  is $raw, $raw, "[$raw]";
  my $request = eval { AnyEvent::Finger::Request->new($raw) };
  diag $@ if $@;
  isa_ok $request, 'AnyEvent::Finger::Request';
  
  is $request->verbose,  1,                       'verbose = 1';
  is $request->username, 'grimlock',              'user = grimlock';
  is "$request",         'grimlock@localhost', 'raw = grimlock@localhost';
  
  is $request->listing_request, 0, 'listing_request = 0';
  is $request->forward_request, 1, 'forward_request = 1';
  
  is_deeply $request->hostnames, ['localhost'], 'hostnames = [localhost]';

};

do {

  my $raw = 'grimlock@localhost@foo@bar@baz';
  is $raw, $raw, "[$raw]";
  my $request = eval { AnyEvent::Finger::Request->new($raw) };
  diag $@ if $@;
  isa_ok $request, 'AnyEvent::Finger::Request';
  
  is $request->verbose,  0,                                'verbose = 0';
  is $request->username, 'grimlock',                       'user = grimlock';
  is "$request",         'grimlock@localhost@foo@bar@baz', 'raw = grimlock@localhost';
  
  is $request->listing_request, 0, 'listing_request = 0';
  is $request->forward_request, 1, 'forward_request = 1';
  
  is_deeply $request->hostnames, [qw( localhost foo bar baz )], 'hostnames = [localhost, foo, bar, baz]';

};

do {

  my $raw = '/W grimlock@localhost@foo@bar@baz';
  is $raw, $raw, "[$raw]";
  my $request = eval { AnyEvent::Finger::Request->new($raw) };
  diag $@ if $@;
  isa_ok $request, 'AnyEvent::Finger::Request';
  
  is $request->verbose,  1,                                   'verbose = 1';
  is $request->username, 'grimlock',                          'user = grimlock';
  is "$request",         'grimlock@localhost@foo@bar@baz', 'raw = grimlock@localhost';
  
  is $request->listing_request, 0, 'listing_request = 0';
  is $request->forward_request, 1, 'forward_request = 1';
  
  is_deeply $request->hostnames, [qw( localhost foo bar baz )], 'hostnames = [localhost, foo, bar, baz]';

};

do {

  my $raw = '';
  is $raw, $raw, "[$raw]";
  my $request = eval { AnyEvent::Finger::Request->new($raw) };
  diag $@ if $@;
  isa_ok $request, 'AnyEvent::Finger::Request';

  is $request->verbose,  0,  'verbose = 0';
  is $request->username, '', 'username = ""';
  is "$request",         '', 'raw = ""';
  
  is $request->listing_request, 1, 'listing_request = 1';
  is $request->forward_request, 0, 'forward_request = 0';
  
  is_deeply $request->hostnames, [], 'hostnames = []';
};

do {

  my $raw = '/W';
  is $raw, $raw, "[$raw]";
  my $request = eval { AnyEvent::Finger::Request->new($raw) };
  diag $@ if $@;
  isa_ok $request, 'AnyEvent::Finger::Request';

  is $request->verbose,  1,  'verbose = 1';
  is $request->username, '', 'username = ""';
  is $request->username, '', 'username = ""';
  is "$request",         '', 'raw = ""';
  
  is $request->listing_request, 1, 'listing_request = 1';
  is $request->forward_request, 0, 'forward_request = 0';
  
  is_deeply $request->hostnames, [], 'hostnames = []';
};