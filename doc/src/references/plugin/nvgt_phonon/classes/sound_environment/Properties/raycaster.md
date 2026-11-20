# raycaster
The object this environment traces rays through, as last set with `set_raycaster()`.

`const ref@ raycaster;`

## Remarks:
This is null until a raycaster has been set, and is not cleared by a call to `set_raycaster()` that fails.
