# load
Load a sound from a file, decoding all of it into memory.

`bool sound::load(const string&in filename, const pack_interface@ pack = sound_default_pack);`

## Arguments:
* const string&in filename: the file to load.
* const pack_interface@ pack = sound_default_pack: the pack to load the file from, or null to load it from disk. By default `sound_default_pack` is used, which is null unless you have set it.

## Returns:
bool: true if the file was found and could be opened, false otherwise.

## Remarks:
Any sound that was loaded before is closed first. Loading happens in the background, so this returns quickly even for a long file, and the sound can be played straight away, starting as soon as enough of it is decoded. `load_complete` says when the whole file has been decoded.

The whole sound is kept in memory, decoded, which makes it quick to play again and to seek, and is best for sound effects. Sounds loaded from the same file share their decoded audio, so loading one sound many times costs little extra memory. For long sounds such as music, which would take a lot of memory, use `stream()` instead.

WAV, OGG Vorbis, Opus, MP3 and FLAC files are supported, as are formats provided by plugins. Files encrypted with the key in `sound_default_decryption_key` are decrypted.
