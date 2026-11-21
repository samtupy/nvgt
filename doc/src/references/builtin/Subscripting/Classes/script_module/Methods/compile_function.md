# compile_function
Compile a single function, optionally adding it to the already built module.

`script_function@ script_module::compile_function(const string&in section_name, const string&in code, array<string>@ errors = null, bool add_to_module = false, uint line_offset = 0);`

## Arguments:
* const string&in section_name: a name for the code, which error messages refer to.
* const string&in code: the code of the function.
* array<string>@ errors = null: if given, receives the error messages, one per array element, each giving the section, line, column and message.
* bool add_to_module = false: whether to add the function to the module, so that other code can call it and it can be found by name. Otherwise it can only be called through the returned handle.
* uint line_offset = 0: a number added to the line numbers in error messages.

## Returns:
script_function@: the compiled function, or null if the code didn't compile.

## Remarks:
This is handy for running a line of code typed by a user, such as in a debug console.
