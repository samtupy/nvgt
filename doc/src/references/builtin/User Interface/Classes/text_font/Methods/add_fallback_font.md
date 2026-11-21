# add_fallback_font
Add a font to supply the characters this font doesn't have.

`bool text_font::add_fallback_font(text_font@ font);`

## Arguments:
* text_font@ font: the fallback font, which should be the same size.

## Returns:
bool: true on success, false otherwise.

## Remarks:
Fallback fonts are tried in the order they were added.
