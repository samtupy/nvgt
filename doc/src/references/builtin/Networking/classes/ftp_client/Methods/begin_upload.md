# begin_upload
Start uploading a file to the server.

`datastream@ ftp_client::begin_upload(const string&in path, const string&in encoding = "", int byteorder = STREAM_BYTE_ORDER_NATIVE);`

## Arguments:
* const string&in path: the path of the file to create on the server.
* const string&in encoding = "": the text encoding of the returned datastream, see datastream.
* int byteorder = STREAM_BYTE_ORDER_NATIVE: the byte order of the returned datastream.

## Returns:
datastream@: a stream that the contents of the file are written to.

## Remarks:
Write the whole file to the stream, and then call end_upload(). The stream is only valid until then and can't be closed by the script. An exception is thrown if the file can't be created or the data connection can't be made.
