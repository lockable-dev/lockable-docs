# Python client

You can use Lockable via the [official Python client](https://pypi.org/project/lockable.dev/). The client provides 2 main benefits:
1. it handles sending period heartbeats to the server via a separate thread
2. it provides a nicer interface via Python `with` statements.

## Install
```bash
pip install lockable-dev
```

## Code
Code can be found in the [GitHub repo](https://github.com/lockable-dev/lockable-py).

## Usage
```python
from lockable import Lock

with Lock('my-lock-name'):
    #do stuff
```

1. The client will attempt to obtain the lock with id `'my-lock-name'`, blocking until the lock is available.
2. Once the lock is acquired, a separate heartbeat thread is launched. This periodically sends a [heartbeat](https-endpoints.md#heartbeat) to Lockable.
3. The code inside the with statement runs.
4. Once the `with` statement is finished running, the lock is automatically released.

## Authentication
All endpoints require users to authenticate via HTTP basic authentication. In order to authenticate, you need to:

1. Acquire your auth token from [your account page](https://lockable.dev/account)
2. Provide the auth token as a username with an empty password.

The Python client will automatically pick up the Auth Token from the environment variable `LOCKABLE_AUTH_TOKEN` and all requests will be automatically authenticated.

## Handling errors
The client provides two callbacks to handle errors:

*  `on_lock_loss()`: this is called if any of the heartbeats returns a `false` response, which indicates the lock has been lost.
*  `on_heartbeat_exception(e)`: this is called if the heartbeat call to Lockable failed due to any reason (e.g. loss of internet connectivity). The exception is passed as an argument to the callback.

Both of these callbacks run on the heartbeat thread.

Usage example:
```python
from lockable import Lock

with Lock(
        'my-lock-name',
        on_lock_loss = lambda:print('Lock has been lost.'),
        on_heartbeat_exception = lambda e:print(f'Heartbeat request has failed due to: {e}')
    ):
    #do stuff
```

## Advanced methods
`lockable` allows you to call the three endpoints directly via:
* `lockable.try_acquire(lock_name)`
* `lockable.try_heartbeat(lock_name)`
* `lockable.try_release(lock_name)`

`try_acquire(lock_name)` attempts to acquire the lock on the `lockable` server. If the lock is not available, this return `False`. If the lock is available, it is acquired and provided a finite lease (60 seconds by default). Once the lease expires, the lock is automatically released.

The main way to refresh the lease is by sending a heartbeat to the server, using `try_heartbeat(lock_name)`. If the lease is refreshed successfully, this returns `True`. If the lease refresh fails (e.g. because the lease has already expired), this returns `False`.

`try_release(lock_name)` immediately releases the lock, making it available for other processes.
