# open
Connect to an FTP server, and log in if a username is given.

`void ftp_client::open(const string&in host, uint16 port, const string&in username = "", const string&in password = "");`

## Arguments:
* const string&in host: the name or address of the server.
* uint16 port: the port of the server, which is 21 for most servers.
* const string&in username = "": the user to log in as, such as "anonymous". If it is empty, call login() afterwards.
* const string&in password = "": the password to log in with.

## Remarks:
An exception is thrown if the connection can't be made or the login is rejected. The welcome message of the server is available in welcome_message once connected.
