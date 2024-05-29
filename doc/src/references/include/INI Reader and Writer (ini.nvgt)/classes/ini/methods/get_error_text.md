# get_error_text
Returns the last error message, almost always used if an ini file fails to load and you want to know why. This function also clears the error, so to figure out the line, call `ini::get_error_line()` before calling this.

`string ini::get_error_text();`

## Returns:
string: the last error message, if any.
