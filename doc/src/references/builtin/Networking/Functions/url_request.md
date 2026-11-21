# url_request
Make an HTTP request with any method and wait for the response.

`string url_request(const string&in method, const string&in url, const string&in data = "", http_response&out response = void);`

## Arguments:
* const string&in method: the method of the request, such as HTTP_PUT or HTTP_DELETE.
* const string&in url: the URL to request, with a scheme of http or https.
* const string&in data = "": the body of the request, if any.
* http_response&out response = void: if given, receives the status and headers of the response.

## Returns:
string: the body of the response, or an empty string if the request failed.

## Remarks:
This blocks the script until the request finishes. To keep the game running during a request, use the http class, which this function uses.
