# progress
How much of the response has been downloaded, from 0.0 to 1.0.

`const float http::progress;`

## Remarks:
This is 0 until the response headers arrive, and -1 if the progress can't be known, such as when the server doesn't send a Content-Length header.
