# get_function_by_name
Find a function of the module by its name.

`script_function@ script_module::get_function_by_name(const string&in name);`

## Arguments:
* const string&in name: the name of the function.

## Returns:
script_function@: the function, or null if the module has no function with that name or has several, in which case use get_function_by_decl().
