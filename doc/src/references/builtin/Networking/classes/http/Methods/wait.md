# wait
Waits for the current request to complete.

`void wait();`

## Remarks:
If no request is in progress, this will return emmedietly. Otherwise, it will block code execution on the calling thread until the request has finished.
