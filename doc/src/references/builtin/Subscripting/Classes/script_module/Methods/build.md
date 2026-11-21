# build
Compile the sections added to the module, replacing any code it held before.

`int script_module::build(array<string>@ errors = null);`

## Arguments:
* array<string>@ errors = null: if given, receives the error messages, one per array element, each giving the section, line, column and message.

## Returns:
int: 0 or more on success, or a negative value if compilation failed.

## Remarks:
The sections are discarded once built, so code must be added again to build the module a second time.

NVGT doesn't initialize the module's global variables when building it, so call reset_globals() after a successful build if the code has globals, or they hold empty values such as 0 and null handles.
