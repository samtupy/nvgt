# dns_resolve_single
Look up the first address of a host.

`spec::ip_address dns_resolve_single(const string&in address);`

## Arguments:
* const string&in address: a host name such as `nvgt.dev`, or an IP address.

## Returns:
spec::ip_address: the first address the host resolved to.

## Remarks:
This blocks until the lookup completes and throws an exception if the host isn't found.
