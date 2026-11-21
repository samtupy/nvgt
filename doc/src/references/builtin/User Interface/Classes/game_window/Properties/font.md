# font
The font text is drawn with by draw_text(), draw_text_wrapped() and draw_menu(), or null if the window has none.

`text_font@ game_window::font;`

## Remarks:
Set it with a handle assignment, as in `@window.font = get_font("arial", 24);`. A window starts with a default font of the platform, Arial or a similar sans serif font where the system has one, so draw_text() works as soon as the window is shown without setting anything. If the platform has no suitable font this is null, which can be checked with `window.font is null`, and text isn't drawn until a font is set.
