# set_option
Set a socket option of the operating system's socket API.

1. `void socket::set_option(int level, int option, int value);`
2. `void socket::set_option(int level, int option, uint value);`
3. `void socket::set_option(int level, int option, uint8 value);`
4. `void socket::set_option(int level, int option, const timespan&in value);`
5. `void socket::set_option(int level, int option, const spec::ip_address&in value);`

## Arguments:
* int level: the protocol level of the option, such as SOL_SOCKET (0xffff on Windows, 1 on Linux) or IPPROTO_TCP (6).
* int option: the option to set, as defined by the operating system.
* int value: the value of the option.

## Remarks:
The common options have properties of their own, such as no_delay and keep_alive, which should be preferred as the numbers differ between operating systems. An exception is thrown if the option can't be set.
