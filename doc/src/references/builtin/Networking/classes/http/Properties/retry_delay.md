# retry_delay
How many milliseconds to wait before sending each request, including the first and every retry after a network error.

`uint http::retry_delay;`

## Remarks:
This defaults to 0. It is kept between requests, and only restored to the default by reset(true).
