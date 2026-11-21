# login
Log in to the server.

`bool smtp_client::login(const string&in username, const string&in password, smtp_auth_method method = SMTP_AUTH_LOGIN);`

## Arguments:
* const string&in username: the username, usually the email address.
* const string&in password: the password, which for many providers must be an app password.
* smtp_auth_method method = SMTP_AUTH_LOGIN: how to authenticate, a value of the smtp_auth_method enum. The server must support the method chosen, which query_server_capabilities() can show.

## Returns:
bool: true if the server accepted the login, false otherwise, with the reason in last_error.
