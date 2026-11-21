# bind_all_imported_functions
Bind every function the module imports from other modules, with statements such as `import void update() from "nvgt_game";`.

`int script_module::bind_all_imported_functions();`

## Returns:
int: 0 or more if every imported function was found and bound, or a negative value otherwise.

## Remarks:
This must be called after build() and before calling any code that uses the imported functions. The game's own module is called nvgt_game.
