# load_complete
Whether a sound loaded with `load()` has finished decoding.

`const bool sound::load_complete;`

## Remarks:
`load()` returns before the file is fully decoded, and the sound can be played straight away. This is needed only when something depends on the whole sound being ready, such as reading its exact `length`.
