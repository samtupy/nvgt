# set_color_mod
Set a color that is multiplied with the image when it is drawn.

`bool graphic::set_color_mod(uint r, uint g, uint b);`

## Arguments:
* uint r: the red component, from 0 to 255.
* uint g: the green component, from 0 to 255.
* uint b: the blue component, from 0 to 255.

## Returns:
bool: true on success.

## Remarks:
Each color of the image is multiplied by the value of its channel divided by 255, so 255 leaves a channel unchanged and 0 removes it. The default is 255 for all three. Values above 255 are not clamped but wrap around, so 300 is treated as 44.
