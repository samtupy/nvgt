# pan_mode
How `pan` moves the audio between the speakers, a value of the audio_pan_mode enum.

`audio_pan_mode mixer::pan_mode;`

## Remarks:
The default, AUDIO_PAN_MODE_BALANCE, lowers the volume of the opposite channel, which keeps a stereo sound's left and right channels where they are. AUDIO_PAN_MODE_PAN moves the audio of both channels towards one side, which is closer to how a mono sound is panned.
