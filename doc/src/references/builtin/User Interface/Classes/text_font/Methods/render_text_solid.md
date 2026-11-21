# render_text_solid
Draw a line of text into a new image quickly, without smoothing its edges.

`graphic@ text_font::render_text_solid(const string&in text, uint r, uint g, uint b);`

## Arguments:
* const string&in text: the text to draw.
* uint r: the red component of the color, from 0 to 255.
* uint g: the green component of the color, from 0 to 255.
* uint b: the blue component of the color, from 0 to 255.

## Returns:
graphic@: the image, or null on failure.
