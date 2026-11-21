# read
Read headers from a stream in the format of an internet message, adding them to the collection.

`bool internet_message_header::read(datastream@ stream);`

## Arguments:
* datastream@ stream: the datastream to read from.

## Returns:
bool: true if the headers were read, false if the stream can't be read from or the headers were malformed or exceeded the limits.

## Remarks:
Reading stops at the blank line that ends the headers, or the end of the stream.
