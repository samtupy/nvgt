# set_status_and_reason
Set the status and reason phrase of the response together.

1. `void http_response::set_status_and_reason(http_status status, const string&in reason);`
2. `void http_response::set_status_and_reason(http_status status);`

## Arguments:
* http_status status: the status, a value of the http_status enum.
* const string&in reason (1): the reason phrase. Without it, the standard phrase for the status is used.
