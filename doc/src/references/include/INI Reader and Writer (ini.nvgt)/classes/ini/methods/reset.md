# reset
Resets all variables to default. You can call this yourself and it is also called by loading functions to clear data from partially successful loads upon error.

`void ini::reset(bool make_blank_section = true);

## Arguments:
* bool make_blank_section = true: this argument is internal, and exists because the `ini::load_string()` function creates that section itself.
