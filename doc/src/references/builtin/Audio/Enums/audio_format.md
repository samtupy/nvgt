# audio_format
This is a list of sample formats, used by `sound::get_data_format()` and `audio_wav_encoder::wav_format`.

* AUDIO_FORMAT_UNKNOWN: the format isn't known.
* AUDIO_FORMAT_U8: unsigned 8 bit integers, centered on 128.
* AUDIO_FORMAT_S16: signed 16 bit integers, the format of most WAV files.
* AUDIO_FORMAT_S24: signed 24 bit integers, packed into 3 bytes.
* AUDIO_FORMAT_S32: signed 32 bit integers.
* AUDIO_FORMAT_F32: 32 bit floating point numbers from -1 to 1, the format NVGT processes audio in.
