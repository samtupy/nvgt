# get_font
Get a font, sharing one object between everything that asks for the same font, size and style.

`text_font@ get_font(const string&in name, float size, uint style = FONT_STYLE_NORMAL, bool allow_caching = true);`

## Arguments:
* const string&in name: the font to load, either the name of an installed font such as `arial`, or the path to a .ttf file.
* float size: the size of the font in points.
* uint style = FONT_STYLE_NORMAL: a combination of values from the font_style enum.
* bool allow_caching = true: whether to share the font. If false, a new font object is always created, which can be changed without affecting anything else.

## Returns:
text_font@: the font. If it couldn't be loaded its methods fail and its family_name is empty.

## Remarks:
Shared fonts stay loaded until NVGT exits. Changing the settings of a shared font, such as its size or style, changes it for everything that uses it.
