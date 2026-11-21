# socket
The base of NVGT's sockets, with the properties and options every socket has.

1. `socket();`
2. `socket(const socket&in sock);`

## Arguments:
* const socket&in sock (2): a socket to share the underlying socket of.

## Remarks:
For networking between the players of a game, the network class is usually a better fit, as it handles connections, reliable and unreliable messages and channels for you.

A socket object on its own is a null socket. Sockets that are actually used are stream_socket and web_socket, which have every method and property of socket as well as their own, and can be made from a socket that really is one of them.

Copying a socket, with the copy constructor or assignment, doesn't copy the connection. Both objects then refer to the same underlying socket, which closes when the last of them is destroyed or close() is called.
