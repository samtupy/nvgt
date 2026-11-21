# http_credentials_is_proxy_ntlm
Find out whether a request's Proxy-Authorization header holds NTLM credentials.

`bool http_credentials_is_proxy_ntlm(const http_request&in request);`

## Arguments:
* const http_request&in request: the request to check.

## Returns:
bool: true if the proxy credentials use the NTLM scheme.
