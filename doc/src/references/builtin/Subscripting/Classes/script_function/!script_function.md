# script_function
A function of a script module, which can be called dynamically and inspected.



## Remarks:
script_function objects are returned by the methods of script_module such as get_function_by_decl(), and by script_module::compile_function().

There are two ways to call one. call() takes a dictionary of arguments and returns a dictionary holding the return value, which works with any function but is slow to write. retrieve() instead stores the function in a handle of a funcdef with the same signature, after which it can be called like any other function.
