# dtx
Whether the encoder sends almost nothing during silence.

`bool audio_opus_encoder::dtx;`

## Remarks:
The default is false. Turning it on saves a lot of bandwidth for voice chat, where people are often silent.
