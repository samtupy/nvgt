# retrieve
Store the function in a handle of a funcdef with the same signature, so it can be called directly.

`bool script_function::retrieve(?&out handle);`

## Returns:
bool: true if the signature of the funcdef matched the function and the handle was set, false otherwise.

## Remarks:
Pass the handle with @, as in `func.retrieve(@my_funcdef_handle)`. Calling through the handle is as fast as calling any other function and needs no dictionaries, which makes it the best way to call a function many times. The return and parameter types must match exactly. See script_module for an example.
