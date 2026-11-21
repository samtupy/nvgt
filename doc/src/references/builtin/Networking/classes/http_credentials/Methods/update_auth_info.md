# update_auth_info
Update the Authorization header of a request that was already authenticated, before sending it again.

`void http_credentials::update_auth_info(http_request&inout request);`

## Arguments:
* http_request&inout request: the request to update.

## Remarks:
Digest authentication requires this for each new request, as it includes a count of the requests made.
