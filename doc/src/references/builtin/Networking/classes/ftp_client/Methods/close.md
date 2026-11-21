# close
Tell the server goodbye and close the connection.

`void ftp_client::close();`

## Remarks:
After this, is_open is false and open() can be used to connect again.
