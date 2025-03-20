# dump
Dump all loaded data into a string.

`string toml_section::dump(bool head, int indent_size = 0, int indent_head_size = 0);`

## Arguments:
- `bool head`: Should the data be prefixed with the section's name if the section name is not empty? For example, if the section is named test, the first line of the data will be `[test]`.
- `int indent_size = 0`: Indentation size. 0 is no indentation.
- `int indent_head_size = 0`: Indentation size for the header. This is the same with `indent_size` argument, but this is for the header itself if the `head` argument will be `true`.

## Returns:
`string`: The entire TOML data of this section as a string.
