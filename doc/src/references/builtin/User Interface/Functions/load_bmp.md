# load_bmp
Load a BMP image file into a graphic.

1. `graphic@ load_bmp(const string&in file)`
2. `graphic@ load_bmp(const string&in file, const pack_interface@ pack_file)`

## Arguments:
* const string&in file: the path of the file to load, or its name in the pack.
* const pack_interface@ pack_file (2): the pack to load the file from.

## Returns:
graphic@: the image, or null if the file is missing or isn't a valid BMP image.

## Remarks:
With a pack, null is also returned if the pack is null or hasn't been opened. See `load_surface()` to load an image of any supported type.
