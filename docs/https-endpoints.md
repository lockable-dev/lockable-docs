# Lockable via HTTPS requests

Lockable exposes 3 different endpoints:

* [acquire](#acquire)
* [heartbeat](#heartbeat)
* [release](#release)

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

> **_NOTE_**: By default, locks go in the same public namespace. When picking a lock name, please make sure the name is unique and has low collision probability. For example `acme-company-foo-system-parallel-batch-job` is a good name. `my-lock` is not. Alternatively, private namespaces are available for Business tier users.

## Release
Once a process is done with the lock, it can release it by calling the `/release` endpoint:
```bash
curl https://api.lockable.dev/v1/release/my-lock-name
```

## Authentication
All endpoints require users to authenticate via HTTP basic authentication. In order to authenticate, you need to:

1. Acquire your auth token from [your account page](https://lockable.dev/account)
2. Provide the auth token as a username with an empty password.

For example, requests done via curl:
```bash
curl https://api.lockable.dev/v1/acquire/my-lock-name -u 00000000-0000-0000-0000-000000000000:
//note the colon at the end of the command
```

Requests done via Python (using the [requests](https://pypi.org/project/requests/) library):
```python
import requests as rq

auth = ('00000000-0000-0000-0000-000000000000', '') #Note the empty password
res = rq.get(f"https://{LOCKABLE_DOMAIN}/v1/heartbeat/my-lock-name", auth=auth)
```

For brevity, for most code examples in this documentation, we will avoid passing in any authentication information.


