# Bank

An interactive banking application that models accounts, transactions,
transfers, a ledger, and JSON persistence.

## Topics included

- Classes and object composition
- Modules and nested namespaces
- Mixins with `include`
- Class-level state and singleton-class accessors
- Constants and frozen collections
- Keyword arguments and default values
- Attribute readers
- Custom exception classes
- Raising and rescuing exceptions
- Input validation and guard conditions
- Immutable value objects with `freeze`
- UUID generation with `SecureRandom`
- Dates, times, and ISO 8601 serialization
- Collection processing with `map`, `inject`, `find`, and `filter_map`
- Symbol-to-Proc shorthand such as `map(&:to_h)`
- Defensive copying with `dup`
- Hash serialization and deserialization
- JSON file persistence
- Interactive command-line input

## Run

From the repository root:

```bash
ruby tasks/bank/main.rb
```

Choosing **Save and quit** updates `accounts.json` in this folder.

