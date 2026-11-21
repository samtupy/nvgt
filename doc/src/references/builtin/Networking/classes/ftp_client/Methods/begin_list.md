# begin_list
Start downloading a listing of a directory.

`datastream@ ftp_client::begin_list(const string&in path = "", bool extended = false, const string&in encoding = "", int byteorder = STREAM_BYTE_ORDER_NATIVE);`

## Arguments:
* const string&in path = "": the directory to list, or a file to get information about only that file. An empty path lists the current working directory.
* bool extended = false: false to get only the names, one per line, or true to get a full listing with sizes, dates and permissions.
* const string&in encoding = "": the text encoding of the returned datastream, see datastream.
* int byteorder = STREAM_BYTE_ORDER_NATIVE: the byte order of the returned datastream.

## Returns:
datastream@: a stream that the text of the listing is read from.

## Remarks:
Read all of the listing from the stream, and then call end_list(). The stream is only valid until then. The format of an extended listing depends on the server and isn't interpreted, so use the names only listing when the result needs to be processed by the game.
