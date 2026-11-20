# complexity
How much processing the encoder spends on quality, from 0 to 10.

`int audio_opus_encoder::complexity;`

## Remarks:
The default is 10, the best quality. Lower values use less processing, which can matter when encoding many streams at once.
