# keep_alive_time
How long, in milliseconds, the network object waits for the script to call request() before it keeps its connections alive by itself.

`uint network::keep_alive_time;`

## Remarks:
Enet only acknowledges packets and sends its pings while the host is being serviced, which normally happens in request(). If a script can't call request() for a while, for example while a modal file dialog from open_file_dialog() is up, while a menu or message box is open, or during a long load, the other end stops hearing from it and drops the connection after 10 to 35 seconds.

To prevent that, once request() hasn't been called for this many milliseconds, a background thread services the network object instead. Whatever arrives meanwhile (received packets, connections and disconnections) is kept, and request() returns it, in the order it came, before anything newer. So nothing is lost, it is just handed to the script once the script is back.

The default is 1000. Set it to 0 to turn this off, so that only request() ever services the host.
