# use_ssl
Whether to encrypt the connection with TLS.

`bool smtp_client::use_ssl;`

## Remarks:
This defaults to false. On port 465 the connection is encrypted from the very first byte, while on any other port, such as 587, it is upgraded with STARTTLS during connect(), which fails if the server doesn't support it. Set it before calling connect().
