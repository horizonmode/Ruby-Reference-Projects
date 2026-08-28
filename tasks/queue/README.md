# Concurrent Worker Pool

A report-processing system that distributes callable tasks across multiple
worker threads and safely collects their results.

## Topics included

- Threads and concurrent execution
- Thread-safe work distribution with `Queue`
- Non-blocking queue reads
- Synchronization with `Mutex`
- Preventing race conditions around shared state
- Creating and joining worker threads
- Handling `ThreadError` when a queue is empty
- Callable objects implementing `call`
- Object composition and dependency injection through constructors
- Keyword arguments
- Transforming collections with `map`
- Creating collections with `Array.new`
- Loop control with `break` and `next`
- Simulating slow work with `sleep`
- Returning structured results with hashes

## Run

From the repository root:

```bash
ruby tasks/queue/main.rb
```

