# set_linger
Set whether closing the socket waits for unsent data to be delivered.

`void socket::set_linger(bool on, int seconds);`

## Arguments:
* bool on: whether to linger when closing.
* int seconds: the longest time to linger for.
