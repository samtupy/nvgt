# lock
Lock the image so that its pixels can be accessed directly.

`bool graphic::lock();`

## Returns:
bool: true on success.

## Remarks:
Every successful lock should be followed by a call to unlock(). There are currently no methods to access the pixels of a graphic from script.
