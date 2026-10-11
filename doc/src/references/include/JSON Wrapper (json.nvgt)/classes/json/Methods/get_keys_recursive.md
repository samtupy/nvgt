# get_keys_recursive
List all keys recursively.

`string[] json::get_keys_recursive() property;`

## Returns:
`string[]`: An array containing all the keys (recursively).

## Remarks:
If the keys are in sub objects, they will be formatted like so:

> section.subsection.key

This also means that you can use this method, loop through the returned array, and use the `opCall` operator to easily return each value.
