# binaural
Whether reflections (and pathed sound) are decoded binaurally with an HRTF when the engine outputs stereo.

`bool binaural;`

## Remarks:
The default is true. When false, or when the engine does not have 2 channels, they are decoded to plain speaker channels, which sounds less spacious on headphones.
