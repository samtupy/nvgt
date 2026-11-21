# socket_select_mode
What socket::poll() waits for, which can be combined with |.

* SOCKET_SELECT_READ: data can be read, or the connection was closed.
* SOCKET_SELECT_WRITE: data can be written, or a non-blocking connection has been made.
* SOCKET_SELECT_ERROR: an error occurred.
