# logout
Log out from the server without closing the connection.

`void ftp_client::logout();`

## Remarks:
Any transfer that is in progress is ended. Use close() instead when you are done with the server.
