package Mojo::File::Role::Ingest;

use Mojo::Base -role, -signatures;
use Mojo::File 'path';
use constant MAX_MEMORY => $ENV{MOJO_MAX_MEMORY_SIZE} || 262144;

our $VERSION = '0.01';

sub ingest {
  my ($self, $class, $opts) = (shift, shift, shift || {});
  return unless defined $class;
  return unless -r $self && !-d _;
  return if $class =~ /[+:]IngestI?$/;
  return
    unless my $composed
    = eval { path(${$self})->with_roles($class, '+IngestI') };
  $opts->{is_large} = !!((-s ${$self}) > MAX_MEMORY);
  $opts->{eol}      //= $/;
  $opts->{encoding} //= 'UTF-8';
  # uncoverable condition false count:1
  # uncoverable condition false count:2
  $opts->{mode}     //= sprintf '<:encoding(%s)' => $opts->{encoding};
  return $composed->parse($opts, @_);
}

1;

=encoding utf8

=begin html

<a href="https://travis-ci.com/kiwiroy/mojo-file-role-ingest">
  <img src="https://travis-ci.com/kiwiroy/mojo-file-role-ingest.svg?token=Kpqpmk91fYg5k9hdqK3y&branch=master">
</a>

=end html

=head1 NAME

Mojo::File::Role::Ingest - Add ingest method to a file.

=head1 SYNOPSIS

  $file = path('file.txt')->with_roles('+Ingest');
  # Mojo::Collection
  $lines = $file->ingest('Mojo::File::Role::Lines');

  @lines;
  $file->ingest('+Lines', {}, sub { push @lines, $_ unless m/^#/ });

  $ext_to_role = {csv => '+CSV', txt => '+Lines'};
  $file->list->each(sub {
    $_->ingest()
  })

=head1 DESCRIPTION

Ingesting the contents of a L<Mojo::File> is a common activity and can be
achieved using L<Mojo::File/"slurp"> to read all the data into memory. Parsing
the data in the file is also a common task and Mojo::File::Role::Ingest provides
a useful syntax to delegate to a L<role|Role::Tiny> that provides a C<parse>
method and have it appropriately consume the file's contents.

A good model is to either return a L<Mojo::Collection> of records from the file
or on a record by record basis call a supplied callback.

=head1 METHODS

Mojo::File::Role::Ingest composes the following method. The examples below use
the included L<Mojo::File::Role::Lines>.

=head2 ingest

  # Mojo::Collection of lines
  $lines = $file->ingest('+Lines');
  
  # same, but change the end of line ($INPUT_RECORD_SEPARATOR)
  $lines = $file->ingest('+Lines', {eol => "//\n"});
  
  # use a callback to collect lines
  @lines;
  $file->ingest('+Lines', {}, sub { push @lines, $_ unless m/^#/ });
  
  # generally
  $file->ingest($role, $options, $cb);

L</"ingest"> delegates to the supplied L<role's|Role::Tiny> C<parse> method. The
C<parse> method will be passed the C<$options> and C<$cb>.

The C<$options> hashref will contain the following keys, as a minimum, when
L</"parse"> is called by L<Mojo::File::Role::Ingest/"ingest">.

=over 4

=item I<encoding>

The encoding to L<Mojo::Util/"decode"> with defaulting to C<UTF-8>.

=item I<eol>

The end of line string defaulting to C<$/>

=item I<is_large>

A Boolean flag to notify if the file has a byte size larger than
C<MOJO_MAX_MEMORY_SIZE>.

=item I<mode>

The mode to open the file with in the case a callback is used and defaulting to
C<<< <:encoding(UTF-8) >>>.

=back

=head1 SEE ALSO

=over 4

=item L<Mojo::File>

=item L<Mojo::File::Role::IngestI>

=item L<Mojo::File::Role::Lines>

=item L<https://github.com/mojolicious/mojo/issues/1392>

=back

=cut
