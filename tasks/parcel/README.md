# Parcel Manifest

A parcel-delivery manifest that behaves like a Ruby collection while adding
domain-specific filtering, ordering, lookup, weight, and batching operations.

## Topics included

- Building a custom collection with `Enumerable`
- Implementing the `each` iteration contract
- Returning an `Enumerator` when no block is supplied
- Lazy filtering with `Enumerator::Lazy`
- Blocks, block parameters, and `block_given?`
- Capturing blocks as Procs with `&predicate`
- Calling Procs and lambdas with `call`
- Constructor-based dependency injection
- Injecting custom sorting behaviour
- Default lambda arguments
- Duck typing through the callable sorter interface
- Standard Enumerable operations including `map`, `find`, `sum`, `group_by`,
  and `max_by`
- Symbol-to-Proc shorthand such as `sum(&:weight)`
- Custom filtered enumerators
- Stateful iteration and weight-based batching
- Guard clauses and argument validation
- Immutable domain objects with `freeze`
- Defensive copying with `dup`
- Constants and frozen collections
- Automated testing with Minitest
- Consuming a finite portion of an infinite source

## Run

From the repository root:

```bash
ruby tasks/parcel/main.rb
```

## Tests

Run only the parcel tests:

```bash
bundle exec ruby -Itest -e 'Dir["test/parcel/**/*_test.rb"].sort.each { |file| require_relative file }'
```

Run the complete repository test suite:

```bash
bundle exec ruby -Itest -e 'Dir["test/**/*_test.rb"].sort.each { |file| require_relative file }'
```

