# max_retries
The maximum number of times a request is sent, counting the requests made to follow redirects, to retry with credentials and to try again after a network error.

`uint http::max_retries;`

## Remarks:
This defaults to 10. When the connection fails or is interrupted, the request is sent again after retry_delay milliseconds, discarding any part of the response body that had already arrived, until it succeeds or the tries run out. A value of 1 means the request is never repeated, though it also means that redirects are not followed. Every redirect and authentication attempt uses up one try as well. It is kept between requests, and only restored to the default by reset(true).
