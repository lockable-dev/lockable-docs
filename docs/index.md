# Welcome to the lockable documentation

[Lockable](https://lockable.dev) is a service providing synchronization locking for distributed systems. Think of it as `flock` but for distributed systems.

## How it works
The core idea is that `lockable` provides a global server which keeps track of whether a lock has been acquired or not. Using these locks, processes can coordinate access to shared resources such as files or queues.

By using `lockable`, you don't have to worry about setting up and running a database or a service like Consul. This makes `lockable` ideal for quick development and iteration.

See common [Use Cases](use-cases.md) for Lockable.

You can use Lockable directly via [HTTPS requests](https-endpoints.md) or via the [Python client](python-client.md)
