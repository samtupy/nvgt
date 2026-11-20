# input_lowpass
The frequency in hertz above which the input is cut before it is reverberated, or 0 not to cut it.

`float audio_fdn_reverb_node::input_lowpass;`

## Remarks:
The default is 2000. Lowering this is the strongest way to make the reverb sound darker, and raising it brightens it.
