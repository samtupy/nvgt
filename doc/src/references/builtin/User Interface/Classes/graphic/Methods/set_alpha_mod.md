# set_alpha_mod
Set an opacity that is multiplied with the image when it is drawn.

`bool graphic::set_alpha_mod(uint alpha);`

## Arguments:
* uint alpha: the opacity from 0, which is fully transparent, to 255, which is fully opaque.

## Returns:
bool: true on success.

## Remarks:
The alpha of each pixel is multiplied by this value divided by 255. The default is 255. Values above 255 wrap around.
