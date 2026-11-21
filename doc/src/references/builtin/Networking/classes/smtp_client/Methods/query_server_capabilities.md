# query_server_capabilities
Ask the server which extensions and authentication methods it supports.

`string smtp_client::query_server_capabilities();`

## Returns:
string: the server's response to the EHLO command, with one capability on each line, such as `AUTH LOGIN PLAIN` and `STARTTLS`, or an empty string if it failed.
