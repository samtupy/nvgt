# unpacket
Copies individual raw bytes from the string (starting at the given offset) into the provided output variables.

`int string::unpacket(int offset, ?&out var1, ...);`

## Arguments:
* offset: Position in the string to start extracting from.
* var1: The first variable slot to fill.

## Returns
A new offset in the string where you should continue the extraction process.

## Remarks
The "..." above denotes that this function can take a variable number of arguments. In fact, it can take up to 16 output variables.

The following snippet will save the string "hello" into five variables named a, b, c, d, and e. These variables can be of any type.
`"hello".unpacket(0, a, b, c, d, e);`

This method does not unpack multi-byte types like 4-byte integers or floats.
