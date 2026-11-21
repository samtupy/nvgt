# transfer_encoding
The transfer encoding of the message, from its Transfer-Encoding header.

`string http_request::transfer_encoding;`

## Remarks:
This is usually HTTP_IDENTITY_TRANSFER_ENCODING, meaning the body is sent as is, or HTTP_CHUNKED_TRANSFER_ENCODING, meaning it is sent in chunks so its length doesn't have to be known in advance.
