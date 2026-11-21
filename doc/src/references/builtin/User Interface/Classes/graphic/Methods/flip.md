# flip
Mirror the image in place.

`bool graphic::flip(flip_mode mode);`

## Arguments:
* flip_mode mode: the direction to flip in, FLIP_HORIZONTAL to mirror left and right or FLIP_VERTICAL to mirror top and bottom.

## Returns:
bool: true on success, or false if mode is FLIP_NONE, as there is nothing to do.

## Remarks:
Both directions are used at once by casting the combined values, as in `image.flip(flip_mode(FLIP_HORIZONTAL | FLIP_VERTICAL))`, which rotates the image by half a turn.
