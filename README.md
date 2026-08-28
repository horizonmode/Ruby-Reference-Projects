# Ruby Learning Projects

A collection of small Ruby programs built to practise the language from its
fundamentals through object-oriented design, persistence, and concurrency.

## Requirements

- Ruby 3.4.7 (see `.ruby-version`)
- Bundler

Install the development dependencies:

```bash
bundle install
```

The bundle currently contains development tooling for Ruby LSP and
Syntax Tree. The example applications otherwise use Ruby's standard library.

### Library

An interactive book checkout exercise. It models books and a library, tracks
checkout state, and records checkout history.

```bash
ruby tasks/book/main.rb
```

### Tournament

A combat tournament demonstrating inheritance, polymorphism, mixins, private
methods, method overriding, and behaviour added to a single object through its
singleton class.

```bash
ruby tasks/tournament/main.rb
```

### Bank

An interactive banking application with accounts, deposits, withdrawals,
transfers, transaction history, custom exceptions, audit output, immutable
transaction objects, and JSON persistence.

```bash
ruby tasks/bank/main.rb
```

Choosing **Save and quit** updates `tasks/bank/accounts.json`.

### Worker pool

A small concurrent report processor built with threads, `Queue`, and `Mutex`.
It distributes callable tasks across a configurable number of workers and
collects their results safely.

```bash
ruby tasks/queue/main.rb
```

## Automated tests

The Minitest suite under `tasks/tests` is a work in progress. Run all current
tests from the repository root with:

```bash
ruby -Itasks/tests -e 'Dir["tasks/tests/**/*_test.rb"].sort.each { |file| require_relative file }'
```

The planned bank test suite covers:

- transaction validation, immutability, and serialization
- deposits, withdrawals, balances, and statements
- transfers and shared transfer identifiers
- ledger account lookup and error handling
- JSON persistence and round trips using temporary files

Tests should be independent, avoid relying on generated UUIDs or the current
time, and never modify the real `tasks/bank/accounts.json` fixture.

## Topics covered

- Collections and enumerable operations
- Classes, inheritance, modules, and mixins
- Encapsulation and method visibility
- Custom exceptions and input validation
- Serialization and file persistence
- Immutable value objects
- Threads and synchronization
- Automated testing with Minitest

## Next steps

Potential areas to explore next include custom enumerators, blocks and Procs,
metaprogramming, pattern matching, Fiber-based concurrency, gem packaging,
profiling, and RBS type signatures.

## License

This project is available under the [MIT License](LICENSE).
