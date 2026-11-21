# has_token
Find out whether a header that holds a comma separated list of tokens contains a token.

`bool internet_message_header::has_token(const string&in name, const string&in token);`

## Arguments:
* const string&in name: the name of the header, such as `Connection`.
* const string&in token: the token to look for, such as `Upgrade`, case insensitively.

## Returns:
bool: true if the header exists and contains the token, false otherwise.
