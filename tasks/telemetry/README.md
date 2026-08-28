# Telemetry Pipeline

This folder is reserved for a mission-control telemetry exercise. The planned
system will process sensor readings, transform them, and generate alerts while
keeping data sources and side effects replaceable.

## Topics to include

- Blocks, `yield`, and `block_given?`
- Procs and lambdas
- Closures and captured state
- Callable objects using `call`
- Higher-order methods
- Implementing a custom `each` method
- Building a custom collection with `Enumerable`
- Returning an `Enumerator` when no block is supplied
- Lazy enumeration and potentially infinite streams
- Constructor-based dependency injection
- Duck-typed dependencies
- Injected data sources, transformers, rules, notifiers, and clocks
- Separating pure data transformations from side effects
- Testing with deterministic fake dependencies

## Status

The scenario has been defined, but its Ruby implementation has not been added
yet.

