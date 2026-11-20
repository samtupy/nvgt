# bitrate
The number of bits per second that the encoder aims for, from 6000 to 510000.

`int audio_opus_encoder::bitrate;`

## Remarks:
The default is 128000. Around 24000 is plenty for speech and 96000 to 128000 for music. Values outside the range are ignored.
