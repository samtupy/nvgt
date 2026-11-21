# measure_string
Find out how much of a line of text fits within a width.

`bool text_font::measure_string(const string&in text, int max_width, int&out measured_width, int&out measured_length) const;`

## Arguments:
* const string&in text: the text to measure.
* int max_width: the width available in pixels.
* int&out measured_width: receives the width of the part that fits.
* int&out measured_length: receives the length in bytes of the part that fits.

## Returns:
bool: true on success, false otherwise.

## Remarks:
This is useful for cutting text off with an ellipsis or wrapping it yourself.
