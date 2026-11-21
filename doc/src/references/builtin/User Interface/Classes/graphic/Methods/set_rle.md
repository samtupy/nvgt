# set_rle
Turn RLE acceleration on or off for the image.

`bool graphic::set_rle(bool enabled);`

## Arguments:
* bool enabled: true to compress the image in memory so that drawing it is faster, false to turn this off.

## Returns:
bool: true on success.

## Remarks:
RLE (run length encoding) helps for images that have large areas of the same color or transparency, at the cost of some memory. It is turned off by default.
