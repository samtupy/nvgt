# audio_ring_buffer
A buffer of a fixed size that audio is written into at one end and read or played from the other.

`audio_ring_buffer(uint channels, uint size, audio_engine@ engine = sound_default_engine);`

## Arguments:
* uint channels: the number of channels of the audio.
* uint size: how many frames the buffer holds.
* audio_engine@ engine = sound_default_engine: the engine to create the buffer in.

## Remarks:
An audio_ring_buffer is an audio_data_source, and has all of its methods and properties as well as the ones listed here. Its audio is taken to be at the engine's sample rate.

Write frames into it with `write()` as they become available, and either read them back with `read()` or let the engine play them by giving the buffer to `sound::open()`. When playing, the buffer must be kept topped up, or the sound goes silent until more frames are written. `sound::stream_pcm()` does this for you in a simpler way.
