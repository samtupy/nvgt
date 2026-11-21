# font
The font text is drawn with by draw_text(), draw_text_wrapped() and draw_menu(), or null if none has been set.

`text_font@ game_window::font;`

## Remarks:
Set it with a handle assignment, as in `@window.font = get_font("arial", 24);`. Windows have no font by default, so text isn't drawn until one is set.
