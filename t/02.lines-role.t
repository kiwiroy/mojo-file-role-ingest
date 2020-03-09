use Mojo::Base -strict;
use Test::More;
use Mojo::File 'path';
use Role::Tiny ();

my $test = path('t/data/short.txt')->with_roles('+Ingest');

my $lines = $test->ingest('+Lines');
is_deeply $lines, ['lorem ipsum dolor', 'Lorem Ipsum Dolor'], 'lines';

$lines = $test->ingest('Mojo::File::Role::Lines', {eol => 'o'});
is_deeply $lines, ['l', 'rem ipsum d', 'l', "r\nL", 'rem Ipsum D', 'l', "r\n"],
  'o used as EOL';

$lines = $test->ingest('Mojo::File::Role::Lines', {eol => qr/ip/i});
is_deeply $lines, ['lorem ', "sum dolor\nLorem ", "sum Dolor\n"],
  'regex used as EOL';

my @lines;
is $test->ingest('+Lines', {}, sub { push @lines, $_ }), '', 'return value';
is_deeply \@lines, ['lorem ipsum dolor', 'Lorem Ipsum Dolor'], 'lines';

@lines = ();
my $res;
{
  local $/ = undef;
  $res = $test->ingest('+Lines', { eol => undef }, sub { push @lines, $_ });
}
is $res, '', 'closed fh';
is_deeply \@lines, ["lorem ipsum dolor\nLorem Ipsum Dolor\n"], 'line';


# encoding
my $enc_test = path('t/data/utf16.txt')->with_roles('+Ingest');
$lines = $enc_test->ingest('+Lines', {encoding => 'UTF-16BE'});
is_deeply $lines, ['✓ Ċalpha-bet', 'second line.'], 'utf16';

# encoding with callback
@lines = ();
is $enc_test->ingest('+Lines', {mode => '<:encoding(UTF-16BE)'},
  sub {
    push @lines, $_;
  }), '', 'closed fh';
is_deeply \@lines, ['✓ Ċalpha-bet', 'second line.'], 'utf16 ok';


done_testing;
