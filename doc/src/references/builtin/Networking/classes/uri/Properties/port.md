# port
The port of the URI.

`uint16 uri::port;`

## Remarks:
If no port was specified, this is the well known port of the scheme if there is one, such as 80 for http and 443 for https, or 0 otherwise. Use specified_port to find out whether a port was given.
