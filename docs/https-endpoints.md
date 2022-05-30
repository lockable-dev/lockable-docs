# Lockable via HTTPS requests

Lockable exposes 3 different endpoints:

## Acquire
You can attempt to acquire a lock by calling `/acquire`:
```bash
curl https://api.lockable.dev/v1/acquire/my-lock-name
```
This returns `{'response': true}` if the lock was acquired successfully, `{'response': false}` otherwise.

If the lock was acquire successfully, all subsequent attempts to acquire it will fail. The lock will remain acquired until either of the following happens:
1. the lock is released via the `/release` endpoint
2. the lease on the lock naturally expires

## Heartbeat
If the process which has acquired a lock unexpectedly dies, there is no way for Lockable to know about it. As a result, processes are expected to send a periodic heartbeat to let the Lockable know they are still alive.

When a lock is acquired, it comes with a lease which starts counting down. The lease starts at 60 seconds for the Hobbyist plan and is configurable for the Business plan. Whenever a heartbeat is sent, the lease is renewed. If the lease lapses without a heartbeat, the lock is automatically released.

```bash
curl https://api.lockable.dev/v1/heartbeat/my-lock-name
```
This returns `{'response': true}` if the lease was renewed successfully, `{'response': false}` otherwise.

## Release
Once a process is done with the lock, it can release it by calling the `/release` endpoint:
```bash
curl https://api.lockable.dev/v1/release/my-lock-name
```
