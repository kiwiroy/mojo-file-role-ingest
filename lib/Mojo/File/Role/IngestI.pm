package Mojo::File::Role::IngestI;

use Mojo::Base -role;

requires 'parse';

1;

=encoding utf8

=head1 NAME

Mojo::File::Role::IngestI - Interface for Ingest

=head1 SYNOPSIS

  # compose Mojo::File::Role::Ingest
  my $obj = Mojo::File->new->with_roles('+Ingest');
  $obj->ingest('+Lines');

=head1 DESCRIPTION

A simple role to ensure composition of Ingest compatible roles have c<parse>.

=head1 METHODS

Mojo::File::Role::IngestI B<requires> the following methods as they will be
called by L<Mojo::File::Role::Ingest/"ingest">.

=head2 parse

  $file->parse($options, $callback);

L<Mojo::File::Role::Ingest/"ingest"> will call L</"parse"> with a hashref
C<$options> and possibly a C<$callback>. If no C<$callback> is supplied the
method is expected to return a L<Mojo::Collection> of I<"things"> that are
defined for the file format being ingested. If a C<$callback> is supplied it is
expected to be called for each record entry in the file being ingested.

The C<$options> hashref will contain the following keys when L</"parse"> is
called by L<Mojo::File::Role::Ingest/"ingest">.

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

=cut
