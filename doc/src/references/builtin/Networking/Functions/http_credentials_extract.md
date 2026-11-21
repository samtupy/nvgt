# http_credentials_extract
Split the user info of a URL into a username and password.

1. `void http_credentials_extract(const string&in user_info, string&out username, string&out password);`
2. `void http_credentials_extract(const spec::uri&in uri, string&out username, string&out password);`

## Arguments:
* const string&in user_info (1): user info such as `user:password`.
* string&out username: receives the username.
* string&out password: receives the password, or an empty string if there is none.
* const spec::uri&in uri (2): a URI whose user info to split.
