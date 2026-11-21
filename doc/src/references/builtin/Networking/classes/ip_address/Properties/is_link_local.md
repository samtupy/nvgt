# is_link_local
Whether this is a link local address, 169.254.0.0/16 for IPv4 or fe80::/10 for IPv6, which only works on the local network segment.

`const bool ip_address::is_link_local;`
