# get_decl
Get the declaration of the function.

`string script_function::get_decl(bool include_object_name, bool include_namespace = true, bool include_param_names = true);`

## Arguments:
* bool include_object_name: whether to include the class name of a method, as in `player::move`.
* bool include_namespace = true: whether to include the namespace of the function.
* bool include_param_names = true: whether to include the names of the parameters.

## Returns:
string: the declaration, such as `int add(int a, int b)`.

## Remarks:
The decl property gives the declaration with the class name and namespace but without parameter names.
