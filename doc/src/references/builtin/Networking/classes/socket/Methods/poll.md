# poll
Wait until the socket is ready for reading or writing, or has an error.

`bool socket::poll(const timespan&inout timeout, int mode) const;`

## Arguments:
* const timespan&inout timeout: the longest time to wait. timespan values are in microseconds, so `timespan(0)` checks without waiting.
* int mode: what to wait for, any combination of the socket_select_mode values combined with |.

## Returns:
bool: true if the socket became ready for any of the modes within the timeout, false otherwise.

## Remarks:
Polling with SOCKET_SELECT_READ and a timeout of 0 is a simple way to check whether data has arrived without blocking the game.
