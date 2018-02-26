formulae.brew.sh
===============

[![Build Status](https://secure.travis-ci.org/Homebrew/formulae.brew.sh.svg)](http://travis-ci.org/Homebrew/formulae.brew.sh)
[![Dependency Status](https://gemnasium.com/Homebrew/formulae.brew.sh.svg)](https://gemnasium.com/Homebrew/formulae.brew.sh)
[![View Performance Data on Skylight](https://badges.skylight.io/status/jut3BrkJo722.svg)](https://oss.skylight.io/app/applications/jut3BrkJo722)
[![Code Climate](https://codeclimate.com/github/Homebrew/formulae.brew.sh/badges/gpa.svg)](https://codeclimate.com/github/Homebrew/formulae.brew.sh)
[![Test Coverage](https://codeclimate.com/github/Homebrew/formulae.brew.sh/badges/coverage.svg)](https://codeclimate.com/github/Homebrew/formulae.brew.sh/coverage)

[![Beerpay](https://img.shields.io/beerpay/koraktor/formulae.brew.sh.svg)](https://beerpay.io/Homebrew/formulae.brew.sh)

formulae.brew.sh is a Rails application that gathers package information from
Homebrew, the macOS package manager.

## Internals

To get information about the packages currently available via Homebrew, the
application has its own clone of Homebrew’s Git repositories. Homebrew's raw
package files, the so called formulae (or formulas) which are Ruby classes, are
used to gather information from the packages.

Because Homebrew isn’t currently optimized for third party access, there is
some need to sandbox Homebrew’s code, so we don't mess up with our
application's code. This is done by forking another Ruby process and using an
`IO#pipe` for inter-process communication (IPC). The formula data is passed as
marshalled `Hash`es from the indexing process (child) to the main process
(parent).

There are other, probably better methods of IPC like shared memory, but piping
was easy to implement and proved to be fast enough even for full indexing with
several hundred formulae.

## Local setup

If you clone the repository from GitHub it’s pretty easy to get started with
a working local copy. Run the following commands to run the application locally:

```bash
$ ./script/bootstrap
$ rake db:seed
$ foreman start
```

## Contribute

formulae.brew.sh is an open-source project. Therefore you are free to help
improving it. There are several ways of contributing to formulae.brew.sh’s
development:

 * Use it and spread the word to existing and new Homebrew users
 * Report problems and request features using the [issue tracker][2].
 * Write patches yourself to fix bugs and implement new functionality.
 * Create a fork on [GitHub][1] and start hacking. Extra points for using
   feature branches and GitHub’s pull requests.

## About the internal naming

“Braumeister” – [ˈbʁaʊmʌɪstəʀ] – is the German word for “master brewer” or
“brewmaster”, the person in charge of beer production.

## License

This code is free software; you can redistribute it and/or modify it under the
terms of the new BSD License. A copy of this license can be found in the
LICENSE file.

## Credits

 * Sebastian Staudt – koraktor(at)gmail.com
 * Andrey Ognevsky – a.ognevsky(at)gmail.com
 * Michiel Staessen – staessenmichiel(at)gmail.com
 * Mike McQuaid – mike(at)mikemcquaid.com

## See also

 * [GitHub project page][1]
 * [GitHub issue tracker][2]
 * [Homebrew][3]
 * [Continuous Integration at Travis CI][5]
 * [Performance Data at Skylight][6]
 * [Dependency status at Gemnasium][4]

Follow formulae.brew.sh on Twitter
[@braumeister_org](http://twitter.com/braumeister_org).

 [1]: https://github.com/Homebrew/formulae.brew.sh
 [2]: https://github.com/Homebrew/formulae.brew.sh/issues
 [3]: https://brew.sh
 [4]: https://gemnasium.com/Homebrew/formulae.brew.sh
 [5]: https://travis-ci.org/Homebrew/formulae.brew.sh
 [6]: https://oss.skylight.io/app/applications/jut3BrkJo722
