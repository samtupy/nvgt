# request
This is the function you'll probably be calling the most when you're dealing with the network object in NVGT. It checks if an event has occured since the last time it checked. If it has, it returns you a network_event handle with info about it.

`network_event@ network::request();`

## Returns:
network_event@: a handle to a `network_event` object containing info about the last received event.
