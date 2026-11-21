# ip_address_family
The families of IP addresses, in the spec namespace, so written as `spec::IP_FAMILY_IPV4` and so on.

* IP_FAMILY_UNKNOWN: the family isn't known.
* IP_FAMILY_unix_local: a Unix domain socket address, a path on the local computer rather than an IP address. On platforms without Unix domain sockets this is the same as IP_FAMILY_UNKNOWN.
* IP_FAMILY_IPV4: an IPv4 address such as 192.168.1.10.
* IP_FAMILY_IPV6: an IPv6 address such as ::1.
