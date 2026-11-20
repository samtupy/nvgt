# audio_pan_mode
This is a list of the ways that `mixer::pan` can move audio between the speakers, used with `mixer::pan_mode`.

* AUDIO_PAN_MODE_BALANCE: lower the volume of the channel on the opposite side, like the balance control of a stereo. A stereo sound's left and right channels stay where they are. This is the default.
* AUDIO_PAN_MODE_PAN: move the audio of both channels towards one side, so that a stereo sound panned fully left plays both of its channels from the left speaker.
