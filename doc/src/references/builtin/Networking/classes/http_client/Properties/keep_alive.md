# keep_alive
Whether the connection is kept open after a request so the next one can reuse it.

`bool http_client::keep_alive;`

## Remarks:
This defaults to false, and is set on each request sent, unless the request sets its own keep_alive.
