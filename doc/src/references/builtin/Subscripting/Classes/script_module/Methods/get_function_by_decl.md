# get_function_by_decl
Find a function of the module by its declaration.

`script_function@ script_module::get_function_by_decl(const string&in decl);`

## Arguments:
* const string&in decl: the declaration of the function, such as `int add(int, int)`. Parameter names may be left out.

## Returns:
script_function@: the function, or null if the module has no function with that declaration.

## Remarks:
This is safer than get_function_by_name(), as it also checks the return and parameter types, which must be right for the call to work.
