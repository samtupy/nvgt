# get_bytes
Get the 16 bytes of the UUID.

`string uuid::get_bytes() const;`

## Returns:
string: the UUID as 16 bytes, in network byte order.

## Remarks:
This is a compact form for storing or sending a UUID, which set_bytes() turns back into one.
