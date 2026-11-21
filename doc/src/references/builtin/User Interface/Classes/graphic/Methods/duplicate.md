# duplicate
Make an independent copy of the image.

`graphic@ graphic::duplicate() const;`

## Returns:
graphic@: the copy, or null on failure.

## Remarks:
Unlike assigning a handle, which refers to the same image, changing the copy doesn't change the original. The pixel format and the color, alpha and blend modes are copied.
