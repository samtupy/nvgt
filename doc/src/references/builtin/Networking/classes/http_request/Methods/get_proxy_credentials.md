# get_proxy_credentials
Get the authentication scheme and information of the request's Proxy-Authorization header.

`void http_request::get_proxy_credentials(string&inout scheme, string&inout auth_info) const;`

## Arguments:
* string&inout scheme: receives the scheme.
* string&inout auth_info: receives the information following the scheme.

## Remarks:
An exception is thrown if the request has no Proxy-Authorization header.
