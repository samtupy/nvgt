# render_text_blended
Draw a line of text into a new image with smooth edges over a transparent background.

`graphic@ text_font::render_text_blended(const string&in text, uint r, uint g, uint b);`

## Arguments:
* const string&in text: the text to draw.
* uint r: the red component of the color, from 0 to 255.
* uint g: the green component of the color, from 0 to 255.
* uint b: the blue component of the color, from 0 to 255.

## Returns:
graphic@: the image, or null on failure.

## Remarks:
This is the best looking way to draw text over anything, and is what game_window::draw_text() uses.
