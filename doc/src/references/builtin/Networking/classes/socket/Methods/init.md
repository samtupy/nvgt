# init
Create the underlying operating system socket for an address family, if it doesn't exist yet.

`void socket::init(int af);`

## Arguments:
* int af: the address family, such as spec::IP_FAMILY_IPV4 or spec::IP_FAMILY_IPV6.

## Remarks:
This is only needed to set options on a socket before it is connected, as connecting creates the socket otherwise.
