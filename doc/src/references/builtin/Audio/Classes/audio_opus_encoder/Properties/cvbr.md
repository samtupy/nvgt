# cvbr
Whether a variable bitrate is constrained to stay close to the target.

`bool audio_opus_encoder::cvbr;`

## Remarks:
The default is false. Constraining it makes the bitrate more predictable, which can help when sending audio over a network.
