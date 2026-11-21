# size
The number of elements in the buffer.

`uint64 memory_buffer::size;`

## Remarks:
This is a count of elements, not bytes, see element_size. Changing it doesn't allocate memory, so it must not be made larger than the memory the buffer refers to.
