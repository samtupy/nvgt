# hf_rolloff
How long the high frequencies ring compared to `t60`, between 0 and 2.

`float audio_fdn_reverb_node::hf_rolloff;`

## Remarks:
The default is 0.5. Real rooms absorb high frequencies more than low ones, so values below 1 sound more natural.
