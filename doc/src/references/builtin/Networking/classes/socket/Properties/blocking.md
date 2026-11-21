# blocking
Whether the socket blocks until operations complete, which is the default.

`bool socket::blocking;`

## Remarks:
A non-blocking socket returns straight away from sending and receiving even when nothing could be done, in which case an exception may be thrown or a negative value returned, so poll() should be used to find out when it is ready.
