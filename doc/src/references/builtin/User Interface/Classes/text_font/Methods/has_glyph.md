# has_glyph
Find out whether the font has a character.

`bool text_font::has_glyph(uint codepoint);`

## Arguments:
* uint codepoint: the Unicode code point of the character, such as 65 for A.

## Returns:
bool: true if the font, or one of its fallback fonts, has a glyph for the character.
