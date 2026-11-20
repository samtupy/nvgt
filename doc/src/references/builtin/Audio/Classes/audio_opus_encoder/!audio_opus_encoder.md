# audio_opus_encoder
An encoder that writes compressed Ogg Opus files, which are small and suit both speech and music.

`audio_opus_encoder(audio_engine@ engine = sound_default_engine);`

## Arguments:
* audio_engine@ engine = sound_default_engine: the engine to create the encoder in.

## Remarks:
An audio_opus_encoder is an audio_encoder, and has all of its methods and properties as well as the ones listed here, which tune the encoding and can be set before or after opening it.

Opus only supports sample rates of 8000, 12000, 16000, 24000 and 48000 hertz internally, so audio at other rates is resampled to 48000 in the file. When encoding to memory, `read()` returns the encoded data so far at any time, which makes this encoder suitable for sending audio such as voice chat over a network as it is recorded.
