# pixel_format
The ways the pixels of a graphic can be stored.

* PIXELFORMAT_UNKNOWN: no format. It can't be used to create an image.
* PIXELFORMAT_INDEX8: 8 bits per pixel, where each is the number of a color in a palette.
* PIXELFORMAT_RGB24: 24 bits per pixel, the bytes red, green and blue in that order, without alpha.
* PIXELFORMAT_BGR24: 24 bits per pixel, the bytes blue, green and red in that order, without alpha.
* PIXELFORMAT_XRGB8888: 32 bits per pixel, 8 unused bits then red, green and blue.
* PIXELFORMAT_XBGR8888: 32 bits per pixel, 8 unused bits then blue, green and red.
* PIXELFORMAT_ARGB8888: 32 bits per pixel, alpha then red, green and blue.
* PIXELFORMAT_RGBA8888: 32 bits per pixel, red, green, blue then alpha.
* PIXELFORMAT_ABGR8888: 32 bits per pixel, alpha then blue, green and red.
* PIXELFORMAT_BGRA8888: 32 bits per pixel, blue, green, red then alpha.
* PIXELFORMAT_RGBA32: the bytes red, green, blue and alpha in that order in memory.
* PIXELFORMAT_ARGB32: the bytes alpha, red, green and blue in that order in memory.
* PIXELFORMAT_BGRA32: the bytes blue, green, red and alpha in that order in memory.
* PIXELFORMAT_ABGR32: the bytes alpha, blue, green and red in that order in memory.

## Remarks:
The 8888 formats store each pixel as one 32 bit number, with the channels named from its most significant bits to its least significant, so how the bytes are laid out in memory depends on the byte order of the computer. The formats ending in 32 are aliases of one of them that are chosen so that the bytes are in the order given, which on the little endian computers that NVGT runs on makes PIXELFORMAT_RGBA32 the same as PIXELFORMAT_ABGR8888, PIXELFORMAT_ARGB32 the same as PIXELFORMAT_BGRA8888, PIXELFORMAT_BGRA32 the same as PIXELFORMAT_ARGB8888 and PIXELFORMAT_ABGR32 the same as PIXELFORMAT_RGBA8888.

PIXELFORMAT_ARGB8888 is the format that most windows use, see game_window::pixel_format.
