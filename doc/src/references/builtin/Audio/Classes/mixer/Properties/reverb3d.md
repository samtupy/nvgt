# reverb3d
The reverb3d that the mixer is sent to, or null if it has none.

`reverb3d@+ mixer::reverb3d;`

## Remarks:
Setting this sends the mixer to the reverb3d from after it is panned, the same as calling `set_reverb3d_at()` with reverb3d_postpan, at a volume that follows its distance from the listener. Set it to null to stop sending the mixer to a reverb. Sending a whole mixer to the reverb rather than each of its sounds is cheaper in the same way as positioning the mixer rather than its sounds.
