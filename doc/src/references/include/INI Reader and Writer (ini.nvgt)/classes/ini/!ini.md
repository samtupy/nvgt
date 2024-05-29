# ini
This constructor just takes an optional filename so you can load an INI file directly on object creation if you want. Note though that doing it this way makes it more difficult to instantly tell if there was a problem do to the lack of a return value, so you must then evaluate ini::get_error_line() == 0 to verify a successful load.

`ini(string filename = "");`

## Arguments:
* string filename = "": an optional filename to load on object creation.
