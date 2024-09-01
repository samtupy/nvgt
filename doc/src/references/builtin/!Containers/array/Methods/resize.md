# resize
Resizes the array to the specified size, and initializes all resulting new elements to their default values.

`void array::resize(uint length);`

## Arguments:
* uint length: how big to resize the array to

## Remarks:
If the new size is smaller than the existing number of elements, items will be removed from the bottom or the end of the aray until the array has exactly the number of items specified in the argument to this method.
