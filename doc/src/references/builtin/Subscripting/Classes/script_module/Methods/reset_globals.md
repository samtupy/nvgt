# reset_globals
Initialize every global variable of the module, or set them back to their initial values, by running their initializers.

`int script_module::reset_globals(array<string>@ errors = null);`

## Arguments:
* array<string>@ errors = null: if given, receives the error messages, one per array element, each giving the section, line, column and message.

## Returns:
int: 0 or more on success, or a negative value on failure.
