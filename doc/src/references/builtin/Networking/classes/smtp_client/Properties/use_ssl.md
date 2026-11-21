# use_ssl
Whether to secure the connection with STARTTLS.

`bool smtp_client::use_ssl;`

## Remarks:
This defaults to false. The connection is upgraded to TLS by login() when the port is 587, so messages should only be sent after logging in.
