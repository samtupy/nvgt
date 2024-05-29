# get_error_line
Return the line the last error took place on if applicable. This does not clear the error information, since one may wish to get the line number and the text which are in 2 different functions. So make sure to call this function before `ini::get_error_text()` if the line number is something you're interested in retrieving.

`int ini::get_error_line();`

## Returns:
int: the line number of the last error, if any. A return value of -1 means that this error is not associated with a line number, and 0 means there is no error in the first place.
