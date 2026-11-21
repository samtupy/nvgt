# load_surface
Load an image file of any supported type into a graphic.

1. `graphic@ load_surface(const string&in file)`
2. `graphic@ load_surface(const string&in file, const pack_interface@ pack_file)`

## Arguments:
* const string&in file: the path of the file to load, or its name in the pack.
* const pack_interface@ pack_file (2): the pack to load the file from.

## Returns:
graphic@: the image, or null if the file is missing or isn't a supported image.

## Remarks:
The type of the image is detected from its contents rather than its name, and includes BMP and PNG. With a pack, null is also returned if the pack is null or hasn't been opened.
