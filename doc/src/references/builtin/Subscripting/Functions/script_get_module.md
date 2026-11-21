# script_get_module
Get a script module by name, creating it if needed.

`script_module@ script_get_module(const string&in name, int mode = 1);`

## Arguments:
* const string&in name: the name of the module. NVGT's own code is in a module called nvgt_game.
* int mode = 1: 0 to only get a module that already exists, 1 to create it if it doesn't, or 2 to always create a new, empty one, discarding any existing module with the name.

## Returns:
script_module@: the module, or null if mode is 0 and there is no module with the name.

## Remarks:
See script_module for an example.
