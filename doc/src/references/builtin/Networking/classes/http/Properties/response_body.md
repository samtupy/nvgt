# response_body
Read and consume any new data from the current request.

`const string response_body;`

## Remarks:
It is important to note that accessing this property will flush the buffer stored in the request. This means that for example you do not want to access http.response_body.length(); because the next time http.response_body is accessed it will be empty or might contain new data.

Proper usage is to continuously append the value of this property to a string or datastream in a loop while h.running is true or h.complete is false.
