# begin_download
Start downloading a file from the server.

`datastream@ ftp_client::begin_download(const string&in path, const string&in encoding = "", int byteorder = STREAM_BYTE_ORDER_NATIVE);`

## Arguments:
* const string&in path: the file to download.
* const string&in encoding = "": the text encoding of the returned datastream, see datastream.
* int byteorder = STREAM_BYTE_ORDER_NATIVE: the byte order of the returned datastream.

## Returns:
datastream@: a stream that the contents of the file are read from.

## Remarks:
Read the whole file from the stream, for example with `read()`, and then call end_download(). The stream is only valid until then and can't be closed by the script. An exception is thrown if the file doesn't exist or the data connection can't be made.
