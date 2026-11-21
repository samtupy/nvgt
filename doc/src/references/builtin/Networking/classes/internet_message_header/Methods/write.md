# write
Write the headers to a stream in the format of an internet message, one `Name: value` line for each, without the blank line that ends them.

`bool internet_message_header::write(datastream@ stream) const;`

## Arguments:
* datastream@ stream: the datastream to write to.

## Returns:
bool: true if the headers were written, false if the stream can't be written to or writing failed.
