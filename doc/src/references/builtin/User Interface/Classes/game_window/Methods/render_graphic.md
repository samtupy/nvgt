# render_graphic
Draw an image.

`bool game_window::render_graphic(graphic@ gfx, float x, float y);`

## Arguments:
* graphic@ gfx: the image to draw, such as one loaded with load_png() or rendered by a text_font.
* float x: the horizontal position of the image's top left corner.
* float y: the vertical position of the image's top left corner.

## Returns:
bool: true on success, false otherwise.
