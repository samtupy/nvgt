# dns_resolve
Look up the name, aliases and addresses of a host.

`dns_host_entry dns_resolve(const string&in address);`

## Arguments:
* const string&in address: a host name such as `nvgt.dev`, or an IP address to look up the name of.

## Returns:
dns_host_entry: the host's entry.

## Remarks:
This blocks until the lookup completes and throws an exception if the host isn't found. See dns_host_entry for an example.
