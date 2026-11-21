# get_function_signature
Get the declaration of a function from a handle to it or from a funcdef.

`string get_function_signature(?&in function);`

## Returns:
string: the declaration of the function, such as `void on_hit(int)`.

## Remarks:
An exception is thrown if what is passed isn't a function handle.
