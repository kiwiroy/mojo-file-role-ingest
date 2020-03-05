use Mojo::Base -strict;
BEGIN { $ENV{MOJO_MAX_MEMORY_SIZE} = 16; }
our $passed_options = {};

package Test::Role::Dummy;
use Mojo::Base -role, -signatures;

sub parse ($self, $opts, @_) {
  $passed_options = $opts;
  return [];
}

1;

package main;
use Mojo::Base -strict;
use Test::More;
use Mojo::File 'path';

my $test = path('t/data/short.txt')->with_roles('+Ingest');
ok $test;
is Role::Tiny::does_role($test, 'Mojo::File::Role::Ingest'), 1, 'composed';

is_deeply $test->ingest('Test::Role::Dummy'), [], 'dummy returns array ref';
is_deeply $passed_options,
  {
  is_large => 1,
  eol      => "\n",
  mode     => '<:encoding(UTF-8)',
  encoding => 'UTF-8'
  },
  'bigger than 16 bytes';

is $test->ingest('+Lines'), undef, 'file too big';


done_testing;
