# load_memory
Load a sound from encoded file data held in a string, such as the contents of a WAV or OGG file.

`bool sound::load_memory(const string&in data);`

## Arguments:
* const string&in data: the bytes of a sound file.

## Returns:
bool: true if the data could be decoded, false otherwise.

## Remarks:
This is useful for sound files that your game has downloaded, generated or unpacked itself. For raw samples rather than a file, use `load_pcm()`.
