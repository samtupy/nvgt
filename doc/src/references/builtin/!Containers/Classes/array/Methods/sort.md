# sort
Sorts an array according to a custom algorithm.

`void array::sort(array::less&in, uint startAt = 0, uint count = uint(-1));`

## Arguments:
* array::less&in: A callback that will be used for comparing items.
* uint startAt: The index to start sorting from (default is 0).
* uint count: The number of elements to sort (default is -1, meaning all elements will be sorted).

## Remarks:
The callback function to define is implemented as:
`funcdef bool array<T>::less(const T&in a, const T&in b);`
where `t` refers to the array's datatype.

It should return true if A is considered less than B, or false otherwise.

Please note the signature must match exactly - parameters must be declared as `const &in` otherwise it will result in a compilation error.
