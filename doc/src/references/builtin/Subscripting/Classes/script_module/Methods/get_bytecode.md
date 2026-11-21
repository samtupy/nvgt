# get_bytecode
Save the compiled code of the module as bytecode, which can be loaded again with set_bytecode() without compiling it.

`string script_module::get_bytecode(bool strip_debug_info);`

## Arguments:
* bool strip_debug_info: whether to leave out the debug information, such as line numbers, which makes the bytecode smaller but error messages less helpful.

## Returns:
string: the bytecode, or an empty string if it couldn't be saved.

## Remarks:
Bytecode can only be loaded by a build of NVGT that registers exactly the same functions and types, so it isn't suitable for storing code that must keep working across versions of NVGT.
