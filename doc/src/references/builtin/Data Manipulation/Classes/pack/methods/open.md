# open
Open a pack to perform operations on it.

`bool pack::open(const string&in filename, uint mode, bool memload = false);`

## Arguments:
* const string&in filename: the name of the pack file to open.
* uint mode: the mode to open the pack in (see `pack_open_modes` for more information).
* bool memload = false: whether or not the pack should be loaded into memory as opposed to on disk.

## Returns:
bool: true if the pack was successfully opened with the given mode, false otherwise.

## Remarks:
To open an embedded pack, prefix it with `*`, like this:

`pack.open("*embedded.dat");`

For BGT compatibility, you can use a single `*` to open the first available embedded pack.

`pack.open("*");`
