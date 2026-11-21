# get_option
Get a socket option of the operating system's socket API.

1. `void socket::get_option(int level, int option, int&out value) const;`
2. `void socket::get_option(int level, int option, uint&out value) const;`
3. `void socket::get_option(int level, int option, uint8&out value) const;`
4. `void socket::get_option(int level, int option, timespan&out value) const;`
5. `void socket::get_option(int level, int option, spec::ip_address&out value);`

## Arguments:
* int level: the protocol level of the option.
* int option: the option to get, as defined by the operating system.
* int&out value: receives the value of the option.

## Remarks:
An exception is thrown if the option can't be read.
