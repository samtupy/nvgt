# to_string
Get the path as a string in a particular style.

`string path::to_string(spec::path_style style = spec::PATH_STYLE_NATIVE) const;`

## Arguments:
* spec::path_style style = spec::PATH_STYLE_NATIVE: the style to write the path in, a value of the path_style enum.

## Returns:
string: the path in the given style.

## Remarks:
Converting a path to a string implicitly, such as by concatenating it, uses the native style.
