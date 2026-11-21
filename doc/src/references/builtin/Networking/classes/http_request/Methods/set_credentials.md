# set_credentials
Set the request's Authorization header.

`void http_request::set_credentials(const string&in scheme, const string&in auth_info);`

## Arguments:
* const string&in scheme: the authentication scheme, such as `Bearer`.
* const string&in auth_info: the information following the scheme, such as a token.

## Remarks:
For username and password authentication, http_credentials can create this header for you.
