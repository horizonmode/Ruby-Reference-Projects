# Elevator Dispatch Simulator

A deterministic, tick-based simulation that assigns passenger journeys to a
fleet of elevators and models movement, doors, capacity, pickups, drop-offs,
pending work, and service outages.

## Topics included

- State-machine design
- Deterministic simulations and discrete ticks
- Object composition and responsibility boundaries
- Constructor-based dependency injection
- Duck-typed scheduler strategies
- Scheduling with prioritized selection criteria
- Directional stop ordering
- Capacity reservation and passenger accounting
- Pending work and retry behaviour
- Service outages and request reassignment
- Immutable journey requests and event objects
- Event histories and defensive copying
- Guard clauses and parameter validation
- Symbols for explicit states
- Custom result objects for state transitions
- Automated testing with Minitest

## State model

An elevator may be moving `up` or `down`, or be `idle`. Its doors are `open` or
`closed`, and its service status is either `available` or `out_of_service`.
Each call to `tick` performs at most one physical action: move one floor, open
doors, close doors, or remain stationary.

The controller owns pending and completed journeys. The injected scheduler
selects an eligible elevator, while each elevator owns its movement, passenger,
and door state.

## Run

From the repository root:

```bash
ruby tasks/elevator/main.rb
```

## Tests

Run only the elevator tests:

```bash
bundle exec ruby -Itest -e 'Dir["test/elevator/**/*_test.rb"].sort.each { |file| require_relative file }'
```

Run the complete repository suite:

```bash
bundle exec ruby -Itest -e 'Dir["test/**/*_test.rb"].sort.each { |file| require_relative file }'
```
