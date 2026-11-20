# stream_pcm
Play raw samples that arrive a piece at a time, such as voice chat received over a network.

1. `bool sound::stream_pcm(const float[]@ data, uint sample_rate = 0, uint channels = 0, uint buffer_size = 0);`
2. `bool sound::stream_pcm(const memory_buffer<float>&in data, uint sample_rate = 0, uint channels = 0, uint buffer_size = 0);`

## Arguments:
* data: the next samples to play, as `float[]`, `int[]`, `int16[]` or `uint8[]`, or a `memory_buffer` of one of those types, interleaved when there is more than one channel.
* uint sample_rate = 0: the number of frames per second, or 0 for the engine's sample rate. Only used by the first call.
* uint channels = 0: the number of channels, or 0 for the engine's channel count. Only used by the first call.
* uint buffer_size = 0: how many frames can be waiting to be played, or 0 for twice the number of frames in the first piece. Only used by the first call.

## Returns:
bool: true if all of the samples were queued, false if they are of a different type from the first call or there wasn't room for all of them.

## Remarks:
The first call closes anything that was loaded before, sets the sound up for streaming and starts playing it. Each later call adds samples to the end of what is waiting to be played, and must use the same type of data as the first. The other arguments are ignored after the first call.

The buffer holds `buffer_size` frames. If more samples arrive than there is room for, because they arrive faster than they are played or the sound isn't playing, those that don't fit are dropped and false is returned. Make the buffer large enough to absorb the jitter of whatever is sending you the audio.

A streamed sound can't be looped, paused or seeked, and playing it again with `play()` discards anything waiting to be played. The method is shown with two of its types, but every type accepted by `load_pcm()` works.
