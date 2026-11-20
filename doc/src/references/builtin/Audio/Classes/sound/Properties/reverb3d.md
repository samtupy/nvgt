# reverb3d
The reverb3d that the sound is sent to, or null if it has none.

`reverb3d@+ sound::reverb3d;`

## Remarks:
Setting this sends the sound to the reverb3d from after it is panned, the same as calling `set_reverb3d_at()` with reverb3d_postpan, at a volume that follows its distance from the listener. Set it to null to stop sending the sound to a reverb. Mixers have this property as well, which sends everything played through the mixer.
