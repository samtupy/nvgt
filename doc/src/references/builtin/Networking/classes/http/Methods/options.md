# options
Start an HTTP OPTIONS request in the background. This asks the server which methods and features the URL supports.

`bool http::options(const spec::uri&in url, const string&in body, const name_value_collection@ headers = null, const http_credentials@ creds = null);`

## Arguments:
* const spec::uri&in url: the URL to request, which must have a scheme of http or https. A string can be passed directly.
* const string&in body: the body of the request, such as form data or JSON.
* const name_value_collection@ headers = null: extra headers to send with the request, such as `{{"Accept", "application/json"}}`.
* const http_credentials@ creds = null: credentials to authenticate with if the server asks for them.

## Returns:
bool: true if the request was started, false if the URL's scheme isn't http or https or a request is already running.

## Remarks:
Any previous request made with this object is reset first. While the request runs, its status_code, response_headers, progress and response_body can be checked, and complete becomes true when it has finished, whether or not it succeeded.
