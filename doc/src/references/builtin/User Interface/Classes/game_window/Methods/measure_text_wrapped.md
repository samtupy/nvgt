# measure_text_wrapped
Measure how large text is when drawn with draw_text_wrapped().

`uint64 game_window::measure_text_wrapped(const string&in text, int wrap_width) const;`

## Arguments:
* const string&in text: the text to measure.
* int wrap_width: the width in pixels at which lines wrap.

## Returns:
uint64: the width in the high 32 bits and the height in the low 32 bits, or 0 if the window has no font.
