# stream
Open a sound from a file, decoding it a little at a time as it plays rather than all at once.

`bool sound::stream(const string&in filename, const pack_interface@ pack = sound_default_pack);`

## Arguments:
* const string&in filename: the file to open.
* const pack_interface@ pack = sound_default_pack: the pack to load the file from, or null to load it from disk. By default `sound_default_pack` is used, which is null unless you have set it.

## Returns:
bool: true if the file could be opened, false otherwise.

## Remarks:
Streaming uses very little memory however long the file is, which makes it right for music and long ambiences. It costs a little more processing while playing than a sound loaded with `load()`, and seeking can be slower.
