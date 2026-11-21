# proxy_authenticate
Add a Proxy-Authorization header to a request in answer to a proxy's response asking for authentication.

`void http_credentials::proxy_authenticate(http_request&inout request, const http_response&in response);`

## Arguments:
* http_request&inout request: the request to add the header to.
* const http_response&in response: the HTTP_PROXY_AUTHENTICATION_REQUIRED response.
