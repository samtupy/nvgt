# measure_text
Measure how large a line of text is when drawn with the window's font.

`uint64 game_window::measure_text(const string&in text) const;`

## Arguments:
* const string&in text: the text to measure.

## Returns:
uint64: the width in the high 32 bits and the height in the low 32 bits, so `size >> 32` is the width and `size & 0xffffffff` the height, or 0 if the window has no font.
