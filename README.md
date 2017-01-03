# NAME

App::OnePif - Read 1Password Interchange Format exports

# VERSION

This document describes App::OnePif version {{\[ version \]}}.

# SYNOPSIS

    use App::OnePif;
    App::OnePif->run(@ARGV);

# DESCRIPTION

This module implements an application to allow you to read 1Password
Interchange Format exports interactively and get info out of them.

Before you go on, remember that `1pif` export directories are
_unencrypted_. This means that they are _not secure_. Look in section
["SEE ALSO"](#see-also) for some projects that work directly on the encrypted
database.

Unless you want to fiddle with the module itself, you are probably
interested into program `1pif`.

# METHODS

All `do_*` methods are actually tied to commands available in the
interactive shell. There are also some aliases set in ["run\_interactive"](#run_interactive).

## DEFAULT\_records

Automatically read records if they are not already loaded.

## DEFAULT\_types

Automatically desume record types from loaded recrods.

## attachments\_for

Get list of attachments for a record.

## clear\_records

Remove all records and autoloaded stuff (e.g. types).

## clipped\_records\_bytype

Get a slice of available records, by type.

## do\_exit

Implementation of command `exit` in the interactive shell.

## do\_file

Implementation of command `file` in the interactive shell.

## do\_help

Implementation of command `help` in the interactive shell.

## do\_list

Implementation of command `list` in the interactive shell.

## do\_print

Implementation of command `print` in the interactive shell.

## do\_quit

Implementation of command `quit` in the interactive shell.

## do\_search

Implementation of command `search` in the interactive shell.

## do\_type

Implementation of command `type` in the interactive shell.

## do\_types

Implementation of command `types` in the interactive shell.

## print

Wrapper for printing out stuff in the interactive shell.

## real\_type

Get name of the _main_ type (resolving aliases if needed).

## run

    App::OnePif->run(@ARGV);

Class method that eventually calls ["run\_interactive"](#run_interactive) (hence,
it does not return).

## run\_interactive

Run the interactive shell. Does not return.

# BUGS AND LIMITATIONS

Report bugs either through RT or GitHub (patches welcome).

# SEE ALSO

On GitHub you can find a few projects for dealing directly with the
original, _encrypted_ version of the 1Password database. For example, you
might want to check out the following projects:

- [https://github.com/georgebrock/1pass](https://github.com/georgebrock/1pass)
- [https://github.com/oggy/1pass](https://github.com/oggy/1pass)
- [https://github.com/robertknight/passcards](https://github.com/robertknight/passcards)

# AUTHOR

Flavio Poletti <polettix@cpan.org>

# COPYRIGHT AND LICENSE

Copyright (C) 2016 by Flavio Poletti <polettix@cpan.org>

This module is free software. You can redistribute it and/or modify it
under the terms of the Artistic License 2.0.

This program is distributed in the hope that it will be useful, but
without any warranty; without even the implied warranty of
merchantability or fitness for a particular purpose.
