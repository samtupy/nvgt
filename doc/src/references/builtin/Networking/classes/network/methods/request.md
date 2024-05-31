# request
This is the function you'll probably be calling the most when you're dealing with the network object in NVGT. It checks if an event has occured since the last time it checked. If it has, it returns you a network_event handle with info about it.

`network_event@ network::request(uint timeout = 0);`

## Arguments:
* uint timeout = 0: an optional timeout on your packet receiving (see remarks for more information).

## Returns:
network_event@: a handle to a `network_event` object containing info about the last received event.

## Remarks:
The timeout parameter is in milliseconds, and it determines how long Enet will wait for new packets before returning control back to the calling application. However, if it receives a packet within the timeout period, it will return and you'll be handed the packet straight away.
