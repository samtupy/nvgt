# save_png
Save the image as a PNG file.

`bool graphic::save_png(const string&in file) const;`

## Arguments:
* const string&in file: the path of the file to write.

## Returns:
bool: true if the file was written, false otherwise.

## Remarks:
An existing file is replaced. PNG files are compressed without losing any information, which makes them the better choice for most images.
