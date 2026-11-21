# get_function_by_index
Get a function of the module by its index.

`script_function@ script_module::get_function_by_index(uint index);`

## Arguments:
* uint index: the index of the function, from 0 to get_function_count() - 1.

## Returns:
script_function@: the function, or null if the index is out of range.

## Remarks:
Together with get_function_count(), this lets every function of the module be listed.
