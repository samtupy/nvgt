# is_site_local
Whether this is a site local address, meaning a private network address such as 10.0.0.0/8, 172.16.0.0/12 or 192.168.0.0/16 for IPv4, or fec0::/10 or a unique local fc00::/7 address for IPv6.

`const bool ip_address::is_site_local;`
