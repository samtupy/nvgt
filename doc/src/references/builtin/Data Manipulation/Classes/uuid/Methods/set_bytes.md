# set_bytes
Set the UUID from its 16 bytes.

`void uuid::set_bytes(const string&in bytes);`

## Arguments:
* const string&in bytes: the 16 bytes of the UUID in network byte order, as returned by get_bytes(). If there are fewer than 16, the UUID is unchanged.
