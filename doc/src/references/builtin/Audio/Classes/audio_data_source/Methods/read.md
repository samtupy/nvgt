# read
Read audio from the source yourself rather than letting the audio engine play it.

`float[]@ audio_data_source::read(uint64 frame_count = 0);`

## Arguments:
* uint64 frame_count = 0: how many frames to read, or 0 for `advised_read_frame_count`.

## Returns:
float[]@: the frames that were read, interleaved, which may be fewer than asked for at the end of the source.

## Remarks:
Reading detaches the source from anything its output is attached to, as a source is either pulled from by the script or played by the engine, not both.
