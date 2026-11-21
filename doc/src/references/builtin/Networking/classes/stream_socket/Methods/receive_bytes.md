# receive_bytes
Receive data from the socket.

1. `string stream_socket::receive_bytes(int length, int flags = 0);`
2. `string stream_socket::receive_bytes(int flags = 0, const timespan&in timeout = 100000);`

## Arguments:
* int length (1): the most bytes to receive.
* int flags = 0: flags for the operating system's receive function, usually 0.
* const timespan&in timeout = 100000 (2): the longest time to wait for data to arrive. timespan values are in microseconds, so the default is a tenth of a second.

## Returns:
string: the data received, or an empty string if the other end has shut down the connection or, for the second overload, if nothing arrived within the timeout.

## Remarks:
The first overload blocks until some data arrives, which may be less than length, unless the socket is non-blocking or has a receive_timeout, in which case an exception is thrown when nothing arrives in time. The second overload receives however much data is available, waiting at most timeout for some to arrive.

Data sent through a stream socket arrives in order but isn't divided into messages, so a single send may arrive across several receives or several sends in one. Games usually prefix each message with its length.

As both overloads can be called with a single int, `receive_bytes(4096)` is ambiguous and doesn't compile, so give the flags as well, as in `receive_bytes(4096, 0)`.
