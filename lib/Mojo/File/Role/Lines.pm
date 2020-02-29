package Mojo::File::Role::Lines;
use Mojo::Base -role, -signatures;
use Mojo::Collection 'c';
use Mojo::Util 'decode';

our $VERSION = '0.01';

sub parse ($self, $opts, $cb = undef) {
  return _readlines($self->open($opts->{mode}), $opts, $cb) if $cb;
  return if $opts->{is_large};
  return c(split $opts->{eol} => decode $opts->{encoding} => $self->slurp);
}

sub _readlines ($fh, $opts, $cb) {
  local $/ = $opts->{eol};
  while (readline $fh) {
    chomp;
    $cb->(decode $opts->{encoding}, $_);
  }
}

1;

=encoding utf8

=head1 NAME

Mojo::File::Role::Lines - Ingest a file as a collection of lines.

=head1 SYNOPSIS

  $file = path('file.txt')->with_roles('+Ingest');
  # Mojo::Collection
  $lines = $file->ingest('+Lines');

  @lines;
  $file->ingest('+Lines', {}, sub { push @lines, $_ unless m/^#/ });

=head1 DESCRIPTION

Ingest a file as a collection of lines or collect lines with a callback.

=head1 METHODS

L<Mojo::File::Role::Lines> implements L<Mojo::File::Role::IngestI> and as such
composes the following methods.

=head2 parse

The L</"parse"> method will either parse the file contents into a
L<Mojo::Collection> of lines, or call the supplied callback once per line.

=over 4

=item encoding

=item eol

=item mode

=back

=cut
