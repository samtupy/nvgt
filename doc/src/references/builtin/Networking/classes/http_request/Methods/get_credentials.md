# get_credentials
Get the authentication scheme and information of the request's Authorization header.

`void http_request::get_credentials(string&inout scheme, string&inout auth_info) const;`

## Arguments:
* string&inout scheme: receives the scheme, such as `Basic` or `Bearer`.
* string&inout auth_info: receives the information following the scheme, such as an encoded username and password or a token.

## Remarks:
An exception is thrown if the request has no Authorization header.
