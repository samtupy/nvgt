# load_pcm
Load a sound from raw samples.

`bool sound::load_pcm(const float[]@ data, int samplerate, int channels);`

`bool sound::load_pcm(const int[]@ data, int samplerate, int channels);`

`bool sound::load_pcm(const int16[]@ data, int samplerate, int channels);`

`bool sound::load_pcm(const uint8[]@ data, int samplerate, int channels);`

`bool sound::load_pcm(const memory_buffer<float>&in data, int samplerate, int channels);`

`bool sound::load_pcm(const memory_buffer<int>&in data, int samplerate, int channels);`

`bool sound::load_pcm(const memory_buffer<int16>&in data, int samplerate, int channels);`

`bool sound::load_pcm(const memory_buffer<uint8>&in data, int samplerate, int channels);`

## Arguments:
* data: the samples, as `float[]`, `int[]`, `int16[]` or `uint8[]`, or a `memory_buffer` of one of those types. When there is more than one channel the samples are interleaved, so a stereo sound's samples go left, right, left, right. Floats go from -1 to 1, and the integer types use their full range, with uint8 centered on 128.
* int samplerate: the number of frames per second, such as 44100.
* int channels: the number of channels, such as 1 for mono or 2 for stereo.

## Returns:
bool: true if the samples could be loaded, false otherwise.

## Remarks:
The samples are copied, so the array can be changed or freed afterwards. This is useful for sounds that your game generates itself, such as synthesized tones, and for audio produced by other parts of NVGT such as text to speech. To play samples that keep arriving, such as from a network, use `stream_pcm()` instead.
