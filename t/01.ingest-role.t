package Test::Role::Dummy;
use Mojo::Base -role;
1;


package main;
use Mojo::Base -strict;
use Test::More;
use Mojo::File 'path';
use Role::Tiny ();

my $test = path('t/data/short.txt')->with_roles('+Ingest');
ok $test;
is Role::Tiny::does_role($test, 'Mojo::File::Role::Ingest'), 1, 'composed';

# failures
is $test->ingest(), undef, 'missing role';
is $test->ingest(undef),      undef, 'missing role';
is $test->ingest('+IngestI'), undef, 'interface is not allowed';
is $test->ingest('+Ingest'),  undef, 'cannot ingest in jest';
is $test->ingest('Mojo::File::Role::Ingest'), undef,
  'nor with full package name';
is $test->ingest('Mojo::File::Role::IngestI'), undef,
  'nor with full package name - interface';

is $test->ingest('Test::Role::Dummy'), undef, 'Role cannot compose';
like $@, qr/missing parse/, 'interface checking';


is_deeply $test->ingest('Mojo::File::Role::Lines'),
  ['lorem ipsum dolor', 'Lorem Ipsum Dolor'], 'lines';
my @lines;
$test->ingest('Mojo::File::Role::Lines', {}, sub { push @lines, shift; });
is_deeply \@lines, ['lorem ipsum dolor', 'Lorem Ipsum Dolor'], 'lines';


# file does not exist
$test = Mojo::File->with_roles('+Ingest')->new('t/data/not/readable.txt');
is Role::Tiny::does_role($test, 'Mojo::File::Role::Ingest'), 1, 'composed';

is $test->ingest('Mojo::File::Role::Lines'), undef, 'cannot be read';


# directory - but what if...
# $self->list->map(sub { $_->ingest($class, $opts, $cb) });
# stub code below, but can be seen that deconvoluting lines per file for example
# involves either a public package variable, or injecting into callback/collect
# stream.
$test = Mojo::File->with_roles('+Ingest')->new('t/data');
is Role::Tiny::does_role($test, 'Mojo::File::Role::Ingest'), 1, 'composed';

is $test->ingest('Mojo::File::Role::Lines'), undef, 'directory';

done_testing;


sub _each_file {
  my ($self, $class, $opts, $cb) = @_;
  return $self->list->each(
    sub {
      my $file = shift;
      $file->ingest(
        $class, $opts,
        sub {
          $cb->(@_, $file);
        }
      );
    }
  ) if $cb;
  return $self->list->map(
    sub {
      shift->ingest($class, $opts);
    }
  );
}
