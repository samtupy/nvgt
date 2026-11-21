# set_passive
Choose between passive and active mode for file transfers.

`void ftp_client::set_passive(bool passive, bool use_rfc1738 = true);`

## Arguments:
* bool passive: true for passive mode, in which the client connects to the server for transfers, or false for active mode, in which the server connects to the client.
* bool use_rfc1738 = true: whether to try the newer EPSV and EPRT commands, which also work with IPv6 and NAT, before falling back to the older PASV and PORT commands.

## Remarks:
Passive mode is the default and is the one that works from behind routers and firewalls. Active mode needs the server to be able to reach the computer that is running your game, and can use the port given to the constructor. The current mode is available in the passive property.
