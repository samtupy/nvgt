# draw_text
Draw a line of text with the window's font.

`void game_window::draw_text(const string&in text, float x, float y, uint r, uint g, uint b);`

## Arguments:
* const string&in text: the text to draw.
* float x: the horizontal position of the text's top left corner.
* float y: the vertical position of the text's top left corner.
* uint r: the red component of the color, from 0 to 255.
* uint g: the green component of the color, from 0 to 255.
* uint b: the blue component of the color, from 0 to 255.

## Remarks:
Nothing is drawn if the window has no font, see the font property.
