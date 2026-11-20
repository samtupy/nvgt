# open
Play audio from an audio_data_source such as an audio_decoder or an audio_ring_buffer.

`bool sound::open(audio_data_source@ datasource);`

## Arguments:
* audio_data_source@ datasource: the source to play, which must be active.

## Returns:
bool: true if the source could be opened, false otherwise.

## Remarks:
This lets a sound play from a source that you have set up yourself, for example a decoder with a loop point, or a ring buffer that you fill. The sound keeps a reference to the source until it is closed.
