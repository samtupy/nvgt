# wildcard_ip_address
Get the wildcard address of an address family, which a server binds to in order to listen on every network interface.

`ip_address spec::wildcard_ip_address(ip_address_family family);`

## Arguments:
* ip_address_family family: the family of the address, a value of the spec::ip_address_family enum.

## Returns:
ip_address: 0.0.0.0 for IPv4 or :: for IPv6.
