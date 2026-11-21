# http_credentials_is_ntlm
Find out whether an authentication header, or the Authorization header of a request, holds NTLM credentials.

1. `bool http_credentials_is_ntlm(const string&in header);`
2. `bool http_credentials_is_ntlm(const http_request&in request);`

## Arguments:
* const string&in header (1): the value of a WWW-Authenticate or Authorization header.
* const http_request&in request (2): a request whose Authorization header to check.

## Returns:
bool: true if the credentials use the NTLM scheme.
