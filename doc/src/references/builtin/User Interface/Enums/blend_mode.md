# blend_mode
The ways a graphic can be combined with the pixels it is drawn onto.

* BLEND_MODE_NONE: no blending, the destination is replaced. `dstRGBA = srcRGBA`.
* BLEND_MODE_BLEND: alpha blending. `dstRGB = (srcRGB * srcA) + (dstRGB * (1 - srcA))` and `dstA = srcA + (dstA * (1 - srcA))`.
* BLEND_MODE_BLEND_PREMULTIPLIED: alpha blending for colors that have already been multiplied by their alpha. `dstRGB = srcRGB + (dstRGB * (1 - srcA))` and `dstA = srcA + (dstA * (1 - srcA))`.
* BLEND_MODE_ADD: additive blending. `dstRGB = (srcRGB * srcA) + dstRGB` and `dstA = dstA`.
* BLEND_MODE_ADD_PREMULTIPLIED: additive blending for premultiplied colors. `dstRGB = srcRGB + dstRGB` and `dstA = dstA`.
* BLEND_MODE_MOD: color modulate. `dstRGB = srcRGB * dstRGB` and `dstA = dstA`.
* BLEND_MODE_MUL: color multiply. `dstRGB = (srcRGB * dstRGB) + (dstRGB * (1 - srcA))` and `dstA = dstA`.

## Remarks:
In the formulas, src is the graphic being drawn and dst is what it is drawn onto, with colors and alpha values ranging from 0 to 1.
