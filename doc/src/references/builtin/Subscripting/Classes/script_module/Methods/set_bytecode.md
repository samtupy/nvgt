# set_bytecode
Load bytecode saved with get_bytecode() into the module, replacing any code it held.

`int script_module::set_bytecode(const string&in code, bool&out debug_info_was_stripped, array<string>@ errors = null);`

## Arguments:
* const string&in code: the bytecode to load.
* bool&out debug_info_was_stripped: receives whether the bytecode was saved without debug information.
* array<string>@ errors = null: if given, receives the error messages, one per array element, each giving the section, line, column and message.

## Returns:
int: 0 or more on success, or a negative value if the bytecode couldn't be loaded.
