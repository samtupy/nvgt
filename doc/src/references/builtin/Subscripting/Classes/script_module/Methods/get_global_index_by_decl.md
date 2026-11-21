# get_global_index_by_decl
Find the index of a global variable by its declaration.

`int script_module::get_global_index_by_decl(const string&in decl);`

## Arguments:
* const string&in decl: the declaration of the global, such as `int counter`.

## Returns:
int: the index of the global, or a negative value if there is none.
