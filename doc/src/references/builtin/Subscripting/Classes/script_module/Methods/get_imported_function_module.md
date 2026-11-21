# get_imported_function_module
Get the name of the module a function is imported from.

`const string script_module::get_imported_function_module(uint index);`

## Arguments:
* uint index: the index of the imported function.

## Returns:
const string: the name of the module, such as nvgt_game, or an empty string if the index is out of range.
