# http_credentials_is_proxy_basic
Find out whether a request's Proxy-Authorization header holds Basic credentials.

`bool http_credentials_is_proxy_basic(const http_request&in request);`

## Arguments:
* const http_request&in request: the request to check.

## Returns:
bool: true if the proxy credentials use the Basic scheme.
