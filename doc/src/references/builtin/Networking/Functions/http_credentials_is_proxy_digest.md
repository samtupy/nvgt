# http_credentials_is_proxy_digest
Find out whether a request's Proxy-Authorization header holds Digest credentials.

`bool http_credentials_is_proxy_digest(const http_request&in request);`

## Arguments:
* const http_request&in request: the request to check.

## Returns:
bool: true if the proxy credentials use the Digest scheme.
