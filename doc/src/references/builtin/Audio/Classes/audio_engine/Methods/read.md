# read
Retrieve rendered audio from the engine.

`float[]@ audio_engine::read(uint64 frame_count);`

## Arguments:
* uint64 frame_count: the number of frames to read, where a frame has one sample for each channel of the engine.

## Returns:
float[]@: the samples, interleaved by channel, as values between -1 and 1. This is `frame_count * channels` values long when audio was available, and shorter, even empty, when it was not, for example when nothing is playing, as the engine reports what its node graph produced.

## Remarks:
Every call advances the engine by the number of frames read, so reading 44100 frames from an engine with a sample rate of 44100 hertz gives and moves it forward by one second. This is how audio is retrieved from an engine created with AUDIO_ENGINE_NO_DEVICE, but it can be called on any engine.
