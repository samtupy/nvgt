# get_data_format
Get the format of the audio that the sound plays.

`bool sound::get_data_format(audio_format&out format, uint32&out channels, uint32&out sample_rate);`

## Arguments:
* audio_format&out format: set to the sample format, a value of the audio_format enum.
* uint32&out channels: set to the number of channels.
* uint32&out sample_rate: set to the sample rate in hertz.

## Returns:
bool: true if the format could be found, false if nothing is loaded.

## Remarks:
Sounds loaded with `load()` or `load_pcm()` are decoded to floating point samples at the engine's sample rate, so this describes them as they are held in memory rather than as they were in the file.
