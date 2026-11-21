# get_imported_function_decl
Get the declaration of a function the module imports.

`const string script_module::get_imported_function_decl(uint index);`

## Arguments:
* uint index: the index of the imported function.

## Returns:
const string: the declaration, or an empty string if the index is out of range.
