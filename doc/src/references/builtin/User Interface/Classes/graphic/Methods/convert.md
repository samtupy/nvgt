# convert
Make a copy of the image in another pixel format.

`graphic@ graphic::convert(pixel_format pixel_format) const;`

## Arguments:
* pixel_format pixel_format: the format of the new image.

## Returns:
graphic@: the converted copy, or null on failure. The original is not changed.

## Remarks:
Converting to a format without an alpha channel discards the transparency.
