# Equipment Hire

An object-oriented booking exercise inspired by the design principles in
*Practical Object-Oriented Design in Ruby*.

## Topics included

- Single-responsibility objects
- Dependency injection
- Duck-typed pricing, delivery, and service collaborators
- Composition and decorators
- Namespaces with Ruby modules
- Immutable value objects
- Custom `Enumerable` collections
- Integer-based money calculations
- Date-range overlap rules
- Deterministic clocks and ID generation
- Cost-effective tests of public interfaces

## Run

From the repository root:

```bash
ruby tasks/equipment_hire/main.rb
```

## Tests

```bash
bundle exec ruby -Itest -e \
  'Dir["test/equipment_hire/**/*_test.rb"].sort.each { |file| require_relative file }'
```

The application entry point is `lib/equipment_hire.rb`. `main.rb` is the
composition root: it selects concrete collaborators and connects them without
containing business calculations.
