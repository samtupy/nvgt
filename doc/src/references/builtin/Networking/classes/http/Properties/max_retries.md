# max_retries
The maximum number of times a request is sent, counting the requests made to follow redirects and to retry with credentials.

`uint http::max_retries;`

## Remarks:
This defaults to 10, which limits how many redirects a request follows. It is kept between requests, and only restored to the default by reset(true).
