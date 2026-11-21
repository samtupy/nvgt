# response_body
The part of the response body that has arrived since this property was last read.

`const string http::response_body;`

## Remarks:
Reading this property removes what it returns from the http object, so that a download can be processed or written to a file as it arrives without keeping all of it in memory. For example, `h.response_body.length()` throws the data away, and the next read returns only what arrived after it. Either append this property to a string or stream in a loop while the request runs, or read it once after the request completes to get the whole body.

The request() method does the same.
