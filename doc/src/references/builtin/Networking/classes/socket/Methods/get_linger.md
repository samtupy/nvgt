# get_linger
Get whether closing the socket waits for unsent data to be delivered.

`void socket::get_linger(bool&out on, int&out seconds);`

## Arguments:
* bool&out on: receives whether the socket lingers when closed.
* int&out seconds: receives the longest time it lingers for.
