# HTTP
These string constants hold standard values used when building HTTP requests and responses with classes such as http_request and http_response.

## Protocol versions
* HTTP_1_0: `HTTP/1.0`.
* HTTP_1_1: `HTTP/1.1`. This is the default version of a new http_request.

## Request methods
* HTTP_GET: `GET`.
* HTTP_POST: `POST`.
* HTTP_PUT: `PUT`.
* HTTP_DELETE: `DELETE`.
* HTTP_HEAD: `HEAD`.
* HTTP_OPTIONS: `OPTIONS`.
* HTTP_PATCH: `PATCH`.

## Message bodies
* HTTP_CHUNKED_TRANSFER_ENCODING: `chunked`, the transfer encoding in which the body is sent in a series of chunks, so its length doesn't need to be known in advance.
* HTTP_IDENTITY_TRANSFER_ENCODING: `identity`, the transfer encoding in which the body is sent as is.
* HTTP_UNKNOWN_CONTENT_LENGTH: -1. This is an int rather than a string, and is the value of a message's `content_length` property when no length has been set.
* HTTP_UNKNOWN_CONTENT_TYPE: an empty string, the value of a message's `content_type` property when no content type has been set.

## Example
```NVGT
void main() {
	http_request request(HTTP_POST, "/scores", HTTP_1_1);
	alert("Method", request.method);
	alert("Version", request.version);
	alert("Content length is unknown", request.content_length == HTTP_UNKNOWN_CONTENT_LENGTH ? "yes" : "no");
}
```
