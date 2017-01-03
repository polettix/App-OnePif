# NAME

1pif - Read 1Password Interchange Format exports, interactively

# VERSION

version 0.1.0

<div>
    <a href="https://travis-ci.org/polettix/App-OnePif">
    <img alt="Build Status" src="https://travis-ci.org/polettix/App-OnePif.svg?branch=master">
    </a>

    <a href="https://www.perl.org/">
    <img alt="Perl Version" src="https://img.shields.io/badge/perl-5.10+-brightgreen.svg">
    </a>

    <a href="https://badge.fury.io/pl/App-OnePif">
    <img alt="Current CPAN version" src="https://badge.fury.io/pl/App-OnePif.svg">
    </a>

    <a href="http://cpants.cpanauthors.org/dist/App-OnePif">
    <img alt="Kwalitee" src="http://cpants.cpanauthors.org/dist/App-OnePif.png">
    </a>

    <a href="http://www.cpantesters.org/distro/A/App-OnePif.html?distmat=1">
    <img alt="CPAN Testers" src="https://img.shields.io/badge/cpan-testers-blue.svg">
    </a>

    <a href="http://matrix.cpantesters.org/?dist=App-OnePif">
    <img alt="CPAN Testers Matrix" src="https://img.shields.io/badge/matrix-@testers-blue.svg">
    </a>
</div>

# EXAMPLE

Run within a 1Password Interchange Format export directory (_caution_, it
is **NOT** encrypted).

    shell$ 1pif
    1password> help
    Available commands:
    * quit (also: q, .q)
       exit the program immediately, exit code is 0
    * exit [code] (also: e)
       exit the program immediately, can accept optional exit code
    * file [filename] (also: f)
       set the filename to use for taking data (default: 'data1.pif')
    * types (also: ts)
       show available types and possible aliases
    * type [wanted] (also: t, use, u)
       get current default type or set it to wanted. It is possible to
       reset the default type by setting type "*" (no quotes)
    * list [type] (also: l)
       get a list for the current set type. By default no type is set
       and the list includes all elements, otherwise it is filtered
       by the wanted type.
       If type parameter is provided, work on specified type instead
       of default one.
    * print [ <id> ] (also: p)
       show record by provided id (look for ids with the list command).
       It is also possible to specify the type, in which case the id
       is interpreted in the context of the specific type.
    * search <query-string> (also: s)
       search for the query-string, literally. Looks for a substring in
       the YAML rendition of each record that is equal to the query-string,
       case-insensitively. If a type is set, the search is restricted to
       that type.

# DESCRIPTION

This program allows you to look into a 1Password Interchange Format
directory exported (again, beware it is **NOT** encrypted!). When you run
it inside a such directory, it will read the relevant `data.1pif` file to
get the list of all records, and allow you to browse through it.

The only real command you have to know is `help`, as it will provide you
all details on the available commands. See ["EXAMPLE"](#example) for an... example.

To get a list of records, use the `list` command (abbreviate it to `l`).

    1password> list
    passwords.Password
         1 Foo
         2 Bar
         ...
    securenotes.SecureNote
         5 Whatever
         6 Hello all...
         ...
    ...

You will notice that each record is associated to a numeric identifier,
that will be the same through the whole session.

1Password assignes a type to each record. You can see which types are
available in your export through command `types` (abbreviated `ts`).

    1password> types
    <*>                         * (accept any type)
                             card (also: cards wallet.financial.CreditCard)
                             form (also: forms webforms.WebForm)
                          license (also: licenses wallet.computer.License)
                             note (also: notes securenotes.SecureNote)
                                p (also: password passwords passwords.Password)
                 system.Tombstone
            system.folder.Regular
        system.folder.SavedSearch

If you only want to work with a specific type with the `list` or `search`
commands, you can set the desired type with command `type` (abbreviated `t`).

    1password> type passwords
    1password> list
         1 Foo
         2 Bar
         ...

The `search` (abbreviated `s`) command does a literal search through a YAML
rendition of each record. It's like using Perl's function `index`, so there
is no regular expressions magic, apart that the search is performed without
caring for the case.

    1password> search foo
         1 Foo

When you want to look at a specific record, use command `print` (abbreviated
`p`) with the numeric identifier of the record you're interested into:

    1password> print 1
    ---
    _id: 1
    contentsHash: f87f3cd8
    createdAt: 1234567890
    location: 'Service or Application Name'
    locationKey: 'service or application name'
    secureContents:
      password: you-wish
    securityLevel: SL5
    title: Foo
    typeName: passwords.Password
    updatedAt: 1234567890
    uuid: FD7E562E94D447DCB8F3C3825F8471D9

All the fields you see come from the 1Password export, except for `_id` that
is added by `1pif`.

To exit from the program, you can use either command `quit` (abbreviated with
`q` or, if you use SQLite, also `.q`) or command `exit` (abbreviated `e`),
in which case you can also pass an exit return code.

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

Copyright (C) 2016 by Flavio Poletti polettix@cpan.org.

This module is free software.  You can redistribute it and/or
modify it under the terms of the Artistic License 2.0.

This program is distributed in the hope that it will be useful,
but without any warranty; without even the implied warranty of
merchantability or fitness for a particular purpose.
