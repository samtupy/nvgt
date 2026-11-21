# bind_imported_function
Bind one imported function to a function of your choice.

`int script_module::bind_imported_function(uint index, script_function@ func);`

## Arguments:
* uint index: the index of the imported function, from 0 to get_imported_function_count() - 1.
* script_function@ func: the function to bind it to, which must have the same signature.

## Returns:
int: 0 or more on success, or a negative value on failure.
