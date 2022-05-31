# Lockable uses cases

## Access to common resource
Imagine you have multiple processes, all trying to update the same file on AWS S3.
By naively letting each process read, modify and then write the contents of the files to S3, you risk losing data due to race conditions:
```
    1. process 1: read file from S3
    2. process 2: read file from S3
    3. process 1: modify local file copy
    4. process 2: modify local file copy
    5. process 1: write local copy to S3
    6. process 2: write local copy to S3
```
In this situation, the changes made by `process 1` will be lost, as process 2 will overwrite whatever `process 1` has written to the file.

Lockable lets you avoid this via the use of synchronization locks:
```
    1. process 1: acquire lock from Lockable
    2. process 2: attempt to acquire lock, but fail
       At this point process 2 is blocked waiting for the lock to be released
    3. process 1: read file
    4. process 1: modify local file copy
    5. process 1: write local copy to S3
    6. process 1: release lock
       At this point, process 2 can acquire the lock and resume work
    7. process 2: acquire lock
    8. process 2: read file
    9. process 2: modify local file copy
   10. process 2: write local copy to S3
```
With this new approach, `process 1` and `process 2` are guaranteed to never overwrite each other's data.

> **_NOTE_**: when picking a lock name, please make sure the lock name is unique and has low collision probability. For example `acme-company-foo-system-parallel-batch-job` is a good name. `my-lock` is not.
