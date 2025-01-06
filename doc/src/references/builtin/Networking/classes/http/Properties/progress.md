# progress
Determine the percentage of the request download (from 0.0 to 1.0.

`const float progress;`

## Remarks:
This property will be 0 if a request is not in progress or if it is not yet in a state where the content length of the download can be known, and -1 if the progress cannot be determined such as if the remote endpoint does not provide a Content-Length header.
