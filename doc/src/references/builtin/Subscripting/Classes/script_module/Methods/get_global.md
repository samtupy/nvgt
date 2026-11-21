# get_global
Get the value of a global variable of the module.

`any@ script_module::get_global(uint index);`

## Arguments:
* uint index: the index of the global, from 0 to get_global_count() - 1, as returned by get_global_index_by_name().

## Returns:
any@: an any holding the value, or null if the index is out of range.

## Remarks:
Integers are given as int64 and floats as double, as an any can't give back narrower numbers, so retrieve them into variables of those types. Objects are given as handles.
