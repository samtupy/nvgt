# http_status
The status codes of HTTP responses, as returned by http::status_code and http_response::status. Codes in the 200s mean success, the 300s redirection, the 400s an error on the client's side and the 500s an error on the server's side.

* HTTP_ACCEPTED: 202, the request was accepted but hasn't been acted on yet.
* HTTP_ALREADY_REPORTED: 208, the members of a collection were already reported.
* HTTP_BAD_GATEWAY: 502, a server the request was passed on to responded badly.
* HTTP_BAD_REQUEST: 400, the request was malformed.
* HTTP_CONFLICT: 409, the request conflicts with the current state of the resource.
* HTTP_CONTINUE: 100, the client should continue sending the request.
* HTTP_CREATED: 201, the request succeeded and created something.
* HTTP_ENCHANCE_YOUR_CALM: 420, the client is being rate limited, from Twitter's old API.
* HTTP_EXPECTATION_FAILED: 417, the server can't meet the request's Expect header.
* HTTP_FAILED_DEPENDENCY: 424, the request failed because another one it depended on failed.
* HTTP_FORBIDDEN: 403, the server refuses the request.
* HTTP_FOUND: 302, the resource is temporarily at the URL in the Location header.
* HTTP_GATEWAY_TIMEOUT: 504, a server the request was passed on to didn't respond in time.
* HTTP_GONE: 410, the resource is gone for good.
* HTTP_IM_A_TEAPOT: 418, the server refuses to brew coffee because it is a teapot.
* HTTP_IM_USED: 226, the response is the result of manipulations applied to the resource.
* HTTP_INSUFFICIENT_STORAGE: 507, the server can't store what is needed to complete the request.
* HTTP_INTERNAL_SERVER_ERROR: 500, the server failed while handling the request.
* HTTP_LENGTH_REQUIRED: 411, the request needs a Content-Length header.
* HTTP_LOCKED: 423, the resource is locked.
* HTTP_LOOP_DETECTED: 508, the server found an infinite loop while processing the request.
* HTTP_METHOD_NOT_ALLOWED: 405, the method isn't allowed for the resource.
* HTTP_MISDIRECTED_REQUEST: 421, the request went to a server that can't respond to it.
* HTTP_MOVED_PERMANENTLY: 301, the resource has moved to the URL in the Location header for good.
* HTTP_MULTIPLE_CHOICES: 300, there are several resources the client could choose from.
* HTTP_MULTI_STATUS: 207, the body holds the statuses of several operations.
* HTTP_NETWORK_AUTHENTICATION_REQUIRED: 511, the client must authenticate to gain network access, such as on a hotel's wifi.
* HTTP_NONAUTHORITATIVE: 203, the response comes from a proxy rather than the server itself.
* HTTP_NOT_ACCEPTABLE: 406, the resource can't be provided in any of the forms the request accepts.
* HTTP_NOT_EXTENDED: 510, the request needs further extensions.
* HTTP_NOT_FOUND: 404, nothing was found at the URL.
* HTTP_NOT_IMPLEMENTED: 501, the server doesn't support what the request needs.
* HTTP_NOT_MODIFIED: 304, the resource hasn't changed since the version the client has.
* HTTP_NO_CONTENT: 204, the request succeeded and there is no body.
* HTTP_OK: 200, the request succeeded.
* HTTP_PARTIAL_CONTENT: 206, the body is the part of the resource asked for with a Range header.
* HTTP_PAYMENT_REQUIRED: 402, reserved for payment being required.
* HTTP_PERMANENT_REDIRECT: 308, the resource has moved to the URL in the Location header for good, and the same method should be used there.
* HTTP_PRECONDITION_FAILED: 412, a precondition in the request's headers wasn't met.
* HTTP_PRECONDITION_REQUIRED: 428, the request must be conditional.
* HTTP_PROCESSING: 102, the server is still working on the request.
* HTTP_PROXY_AUTHENTICATION_REQUIRED: 407, the request needs authentication with the proxy.
* HTTP_REQUESTED_RANGE_NOT_SATISFIABLE: 416, the range asked for can't be provided.
* HTTP_REQUEST_ENTITY_TOO_LARGE: 413, the body of the request is too large.
* HTTP_REQUEST_HEADER_FIELDS_TOO_LARGE: 431, the request's headers are too large.
* HTTP_REQUEST_TIMEOUT: 408, the server gave up waiting for the request.
* HTTP_REQUEST_URI_TOO_LONG: 414, the URI of the request is too long.
* HTTP_RESET_CONTENT: 205, the request succeeded and the client should reset its form.
* HTTP_SEE_OTHER: 303, the response can be found at the URL in the Location header with a GET request.
* HTTP_SERVICE_UNAVAILABLE: 503, the server is temporarily unable to handle the request, such as when overloaded or down for maintenance.
* HTTP_SWITCHING_PROTOCOLS: 101, the server is switching to the protocol the client asked for, such as when starting a web socket.
* HTTP_TEMPORARY_REDIRECT: 307, the resource is temporarily at the URL in the Location header, and the same method should be used there.
* HTTP_TOO_EARLY: 425, the server won't process a request that might be replayed.
* HTTP_TOO_MANY_REQUESTS: 429, the client has sent too many requests and is being rate limited.
* HTTP_UNAUTHORIZED: 401, the request needs authentication.
* HTTP_UNAVAILABLE_FOR_LEGAL_REASONS: 451, the resource is unavailable for legal reasons.
* HTTP_UNPROCESSABLE_ENTITY: 422, the request was well formed but its content was invalid.
* HTTP_UNSUPPORTED_MEDIA_TYPE: 415, the server doesn't support the type of the request's body.
* HTTP_UPGRADE_REQUIRED: 426, the client must switch to another protocol.
* HTTP_USE_PROXY: 305, the resource must be accessed through a proxy.
* HTTP_VARIANT_ALSO_NEGOTIATES: 506, the server is misconfigured.
* HTTP_VERSION_NOT_SUPPORTED: 505, the server doesn't support the HTTP version of the request.

http_status_reason() gives the standard reason phrase for any of these.
