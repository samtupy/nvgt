# open
Open a sound file or stream for decoding.

`bool audio_decoder::open(const string&in filename, const pack_interface@ pack_file = sound_default_pack, uint sample_rate = 0, uint channels = 0);`

`bool audio_decoder::open(datastream@ stream, uint sample_rate = 0, uint channels = 0);`

## Arguments:
* const string&in filename (1): the file to open.
* const pack_interface@ pack_file = sound_default_pack (1): the pack to open the file from, or null for disk.
* datastream@ stream (2): a stream to decode from, such as a file or a network connection.
* uint sample_rate = 0: the sample rate to convert the audio to, or 0 to keep the file's own.
* uint channels = 0: the number of channels to convert the audio to, or 0 to keep the file's own.

## Returns:
bool: true if the audio could be opened, false otherwise.

## Remarks:
Anything that was open before is closed first. A stream that can't seek, such as a live connection, can still be decoded.
