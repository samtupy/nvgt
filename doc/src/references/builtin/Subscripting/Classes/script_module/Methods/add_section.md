# add_section
Add a section of code to the module, to be compiled by the next build().

`int script_module::add_section(const string&in name, const string&in code, uint line_offset = 0);`

## Arguments:
* const string&in name: the name of the section, usually the filename it came from, which error messages refer to.
* const string&in code: the code of the section.
* uint line_offset = 0: a number added to the line numbers in error messages, for code that begins part way into a file.

## Returns:
int: 0 or more on success, or a negative AngelScript error code.

## Remarks:
Sections can't use `#include` or other preprocessor directives, as the code is given straight to the compiler.
