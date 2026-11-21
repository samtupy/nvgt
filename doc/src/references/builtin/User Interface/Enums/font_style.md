# font_style
Styles of a text_font, which can be combined with a verticle bar (| bitwise).

* FONT_STYLE_NORMAL: no styling.
* FONT_STYLE_BOLD: bold text.
* FONT_STYLE_ITALIC: italic text.
* FONT_STYLE_UNDERLINE: underlined text.
* FONT_STYLE_STRIKETHROUGH: struck through text.

Bold and italic are synthesized when the font has no bold or italic version, so loading the font's own bold or italic file looks better where there is one.
