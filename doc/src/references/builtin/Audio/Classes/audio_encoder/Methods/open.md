# open
Start encoding to memory, to a file or to a stream.

`bool audio_encoder::open(uint sample_rate, uint channels, uint flags = AUDIO_ENCODER_DEFAULTS);`

`bool audio_encoder::open(const string&in filename, uint sample_rate, uint channels, uint flags = AUDIO_ENCODER_DEFAULTS);`

`bool audio_encoder::open(datastream@ stream, uint sample_rate, uint channels, uint flags = AUDIO_ENCODER_DEFAULTS);`

## Arguments:
* const string&in filename (2): the file to write to.
* datastream@ stream (3): a stream to write to, which must be writable.
* uint sample_rate: the sample rate of the encoded audio. It is converted from the engine's sample rate if they differ.
* uint channels: the number of channels of the encoded audio. It is converted from the engine's number of channels if they differ.
* uint flags = AUDIO_ENCODER_DEFAULTS: a combination of the audio_encoder_flags enum and the flags of the particular encoder, such as the sample format of a WAV file from audio_wav_encoder_flags.

## Returns:
bool: true if the encoder was opened.

## Remarks:
The first form encodes into memory, and the encoded data is collected with `read()`. Anything open before is closed first.
