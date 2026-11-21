# get_string_size_wrapped
Measure text wrapped onto lines no wider than a width.

`bool text_font::get_string_size_wrapped(const string&in text, int wrap_width, int&out w, int&out h) const;`

## Arguments:
* const string&in text: the text to measure.
* int wrap_width: the width in pixels at which lines wrap, or 0 to only break lines at newlines.
* int&out w: receives the width in pixels.
* int&out h: receives the height in pixels.

## Returns:
bool: true on success, false otherwise.
