# authenticate
Add an Authorization header to a request in answer to a server's response asking for authentication.

`void http_credentials::authenticate(http_request&inout request, const http_response&in response);`

## Arguments:
* http_request&inout request: the request to add the header to, which should then be sent again.
* const http_response&in response: the HTTP_UNAUTHORIZED response, whose WWW-Authenticate header says which scheme to use.

## Remarks:
An exception is thrown if the server asks for a scheme that isn't supported.
