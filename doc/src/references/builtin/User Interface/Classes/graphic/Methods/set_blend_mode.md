# set_blend_mode
Set how the image is combined with what it is drawn onto.

`bool graphic::set_blend_mode(blend_mode mode);`

## Arguments:
* blend_mode mode: the way to blend, see the blend_mode enum.

## Returns:
bool: true on success.

## Remarks:
The default is BLEND_MODE_BLEND for images with an alpha channel, and BLEND_MODE_NONE for those without.
