# url_post
Make an HTTP POST request and wait for the response.

`string url_post(const string&in url, const string&in data, http_response&out response = void);`

## Arguments:
* const string&in url: the URL to post to, with a scheme of http or https.
* const string&in data: the body of the request. Unless the request says otherwise, servers take it to be form data, such as `name=Sam&score=1500`.
* http_response&out response = void: if given, receives the status and headers of the response.

## Returns:
string: the body of the response, or an empty string if the request failed.

## Remarks:
This blocks the script until the request finishes. To keep the game running during a request, use the http class, which this function uses. The request is sent with a Content-Type of application/x-www-form-urlencoded, url_encode() can encode the values in it.
