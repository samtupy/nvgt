# login
Log in to the server.

`void ftp_client::login(const string&in username, const string&in password);`

## Arguments:
* const string&in username: the user to log in as.
* const string&in password: the password to log in with.

## Remarks:
This has to be called after open() if no username was given to it, before any other commands except close(). An exception is thrown if the server rejects the login.
