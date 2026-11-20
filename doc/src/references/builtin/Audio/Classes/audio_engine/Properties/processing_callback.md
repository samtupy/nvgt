# processing_callback
A function that is called with each block of audio that the engine has produced, which can be used to look at or change the sound just before it reaches the device.

`audio_engine_processing_callback@ audio_engine::processing_callback;`

## Remarks:
The signature of the callback is:

> void audio_engine_processing_callback(audio_engine@ engine, memory_buffer<float>& data, uint64 frames);

The data holds `frames` frames of interleaved samples, and anything written to it is heard. This function runs on the audio thread, so it must be fast and shouldn't wait on anything, or the audio will stutter. It is not called by engines without a device, which return their audio from `read()` instead. Set it to null to remove it.
