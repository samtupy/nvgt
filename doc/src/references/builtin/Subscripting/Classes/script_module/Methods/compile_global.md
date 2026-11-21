# compile_global
Compile a single global variable and add it to the already built module.

`int script_module::compile_global(const string&in section_name, const string&in code, array<string>@ errors = null, uint line_offset = 0);`

## Arguments:
* const string&in section_name: a name for the code, which error messages refer to.
* const string&in code: the declaration of the variable, such as `int lives = 3;`.
* array<string>@ errors = null: if given, receives the error messages, one per array element, each giving the section, line, column and message.
* uint line_offset = 0: a number added to the line numbers in error messages.

## Returns:
int: 0 or more on success, or a negative value if the code didn't compile.
