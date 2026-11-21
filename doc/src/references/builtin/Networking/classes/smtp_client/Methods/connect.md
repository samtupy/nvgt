# connect
Connect to the server and greet it.

`bool smtp_client::connect();`

## Returns:
bool: true if the connection was made, false otherwise, with the reason in last_error.

## Remarks:
Any existing connection is closed first.
