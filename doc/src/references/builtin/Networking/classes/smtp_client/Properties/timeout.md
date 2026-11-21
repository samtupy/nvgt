# timeout
How many milliseconds to wait for the server to respond before giving up.

`int smtp_client::timeout;`

## Remarks:
This defaults to 30000, 30 seconds, and takes effect on the next connect().
