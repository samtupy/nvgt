# mask
Mask the address, keeping only the bits that are set in a mask.

1. `void ip_address::mask(const spec::ip_address&in mask);`
2. `void ip_address::mask(const spec::ip_address&in mask, const spec::ip_address&in set);`

## Arguments:
* const spec::ip_address&in mask: the mask to apply, such as 255.255.255.0.
* const spec::ip_address&in set (2): an address whose bits replace the bits removed by the mask.

## Remarks:
This only works with IPv4 addresses.
