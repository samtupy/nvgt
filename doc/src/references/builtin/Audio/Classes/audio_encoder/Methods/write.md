# write
Encode frames.

1. `uint audio_encoder::write(const float[]@ frames);`
2. `uint audio_encoder::write(const memory_buffer<float>& frames);`

## Arguments:
* frames: the samples to encode, interleaved and in the engine's number of channels.

## Returns:
uint: the number of frames that were encoded.

## Remarks:
Audio can also be encoded by attaching nodes to the encoder, see the remarks of audio_encoder.
