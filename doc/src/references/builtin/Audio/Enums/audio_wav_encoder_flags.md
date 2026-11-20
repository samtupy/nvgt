# audio_wav_encoder_flags
This is a list of the sample formats that an audio_wav_encoder can write, passed to `audio_encoder::open()`.

* AUDIO_ENCODER_WAV_U8: 8 bit, which is small but noisy.
* AUDIO_ENCODER_WAV_S16: 16 bit, CD quality and the most widely supported. This is the default.
* AUDIO_ENCODER_WAV_S24: 24 bit.
* AUDIO_ENCODER_WAV_S32: 32 bit integer.
* AUDIO_ENCODER_WAV_F32: 32 bit floating point, which keeps NVGT's audio exactly.

Choose one and combine it with any of the audio_encoder_flags, for example `AUDIO_ENCODER_WAV_F32 | AUDIO_ENCODER_OVERWRITE`.
