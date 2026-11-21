# create_surface
Create a new, blank graphic.

`graphic@ create_surface(int width, int height, pixel_format pixel_format);`

## Arguments:
* int width: the width of the image in pixels.
* int height: the height of the image in pixels.
* pixel_format pixel_format: how the pixels are stored, such as PIXELFORMAT_ARGB8888 for an image with transparency.

## Returns:
graphic@: the new image, or null if the size is negative or the format is PIXELFORMAT_UNKNOWN.
