# no_delay
Whether Nagle's algorithm is disabled for the socket (TCP_NODELAY), so that small amounts of data are sent straight away rather than being collected into larger packets.

`bool socket::no_delay;`

## Remarks:
Enabling this lowers latency, which suits games that send many small messages.
