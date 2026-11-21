# login_oauth2
Log in to the server with an OAuth2 access token, which providers such as Gmail and Outlook prefer.

`bool smtp_client::login_oauth2(const string&in username, const string&in access_token);`

## Arguments:
* const string&in username: the email address to log in as.
* const string&in access_token: an OAuth2 access token for the account, obtained from the provider.

## Returns:
bool: true if the server accepted the login, false otherwise, with the reason in last_error.
