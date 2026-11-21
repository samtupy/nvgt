# get_imported_function_index
Find the index of an imported function by its declaration.

`int script_module::get_imported_function_index(const string&in decl);`

## Arguments:
* const string&in decl: the declaration of the imported function.

## Returns:
int: the index, or a negative value if the module doesn't import such a function.
