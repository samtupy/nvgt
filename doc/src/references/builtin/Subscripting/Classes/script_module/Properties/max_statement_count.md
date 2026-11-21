# max_statement_count
The default for the most statements a function of this module may run before it is stopped.

`uint script_module::max_statement_count;`

## Remarks:
This defaults to 0, which means no limit. It is used by script_function::call() and script_function::opCall() on any function of this module when they are not given a max_statement_count of their own, and it is stored with the module, so every script_module object for the same module sees the same value. Limiting the statements of code that came from somewhere you don't control protects the game from code that never returns.
