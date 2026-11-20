# input_highpass
The frequency in hertz below which the input is cut before it is reverberated, or 0 not to cut it.

`float audio_fdn_reverb_node::input_highpass;`

## Remarks:
The default is 0. Raising this keeps rumble and bass out of the reverb, which can stop a large space from sounding muddy.
