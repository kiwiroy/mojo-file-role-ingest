<div>
    <a href="https://travis-ci.com/kiwiroy/mojo-file-role-ingest">
      <img src="https://travis-ci.com/kiwiroy/mojo-file-role-ingest.svg?token=Kpqpmk91fYg5k9hdqK3y&branch=master">
    </a>
</div>

# NAME

Mojo::File::Role::Ingest - Add ingest method to a file.

# SYNOPSIS

    $file = path('file.txt')->with_roles('+Ingest');
    # Mojo::Collection
    $lines = $file->ingest('Mojo::File::Role::Lines');

    @lines;
    $file->ingest('+Lines', {}, sub { push @lines, $_ unless m/^#/ });

    $ext_to_role = {csv => '+CSV', txt => '+Lines'};
    $file->list->each(sub {
      $_->ingest()
    })

# DESCRIPTION

Ingesting the contents of a [Mojo::File](https://metacpan.org/pod/Mojo%3A%3AFile) is a common activity and can be
achieved using ["slurp" in Mojo::File](https://metacpan.org/pod/Mojo%3A%3AFile#slurp) to read all the data into memory. Parsing
the data in the file is also a common task and Mojo::File::Role::Ingest provides
a useful syntax to delegate to a [role](https://metacpan.org/pod/Role%3A%3ATiny) that provides a `parse`
method and have it appropriately consume the file's contents.

A good model is to either return a [Mojo::Collection](https://metacpan.org/pod/Mojo%3A%3ACollection) of records from the file
or on a record by record basis call a supplied callback.

# METHODS

Mojo::File::Role::Ingest composes the following method. The examples below use
the included [Mojo::File::Role::Lines](https://metacpan.org/pod/Mojo%3A%3AFile%3A%3ARole%3A%3ALines).

## ingest

    # Mojo::Collection of lines
    $lines = $file->ingest('+Lines');
    
    # same, but change the end of line ($INPUT_RECORD_SEPARATOR)
    $lines = $file->ingest('+Lines', {eol => "//\n"});
    
    # use a callback to collect lines
    @lines;
    $file->ingest('+Lines', {}, sub { push @lines, $_ unless m/^#/ });
    
    # generally
    $file->ingest($role, $options, $cb);

["ingest"](#ingest) delegates to the supplied [role's](https://metacpan.org/pod/Role%3A%3ATiny) `parse` method. The
`parse` method will be passed the `$options` and `$cb`.

The `$options` hashref will contain the following keys, as a minimum, when
["parse"](#parse) is called by ["ingest" in Mojo::File::Role::Ingest](https://metacpan.org/pod/Mojo%3A%3AFile%3A%3ARole%3A%3AIngest#ingest).

- _encoding_

    The encoding to ["decode" in Mojo::Util](https://metacpan.org/pod/Mojo%3A%3AUtil#decode) with defaulting to `UTF-8`.

- _eol_

    The end of line string defaulting to `$/`

- _is\_large_

    A Boolean flag to notify if the file has a byte size larger than
    `MOJO_MAX_MEMORY_SIZE`.

- _mode_

    The mode to open the file with in the case a callback is used and defaulting to
    `<:encoding(UTF-8)`.

# SEE ALSO

- [Mojo::File](https://metacpan.org/pod/Mojo%3A%3AFile)
- [Mojo::File::Role::IngestI](https://metacpan.org/pod/Mojo%3A%3AFile%3A%3ARole%3A%3AIngestI)
- [Mojo::File::Role::Lines](https://metacpan.org/pod/Mojo%3A%3AFile%3A%3ARole%3A%3ALines)
- [https://github.com/mojolicious/mojo/issues/1392](https://github.com/mojolicious/mojo/issues/1392)
