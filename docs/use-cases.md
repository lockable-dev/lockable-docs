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


## Ensure a single instance of a process is running
It's common to have various scripts run periodically (e.g. data processing steps in ETL pipelines, backup jobs etc). Most of the times the assumption is that these jobs will only have a single instance running at a time. This leads to instances where, due to processing slowness, running jobs do not finish before newly scheduled jobs are launched.

Using `lockable`, you can ensure a single instance of a process is running at any given time, by making sure your logic is only executed if the associated lock can be acquired. e.g.

```
1. acquire lock.
  1.a. if acquisiton fails, either exit, or retry after a set amount
2. run the script
3. release lock
```
