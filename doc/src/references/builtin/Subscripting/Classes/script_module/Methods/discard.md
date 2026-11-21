# discard
Remove the module and its code from the engine.

`void script_module::discard();`

## Remarks:
Its functions can't be called after this, so be sure nothing still holds them. The memory is freed once nothing refers to the module's code.
