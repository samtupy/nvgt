# spatialization_enabled
Whether the mixer is positioned in 3d space, being panned and attenuated by its position relative to the listener.

`bool mixer::spatialization_enabled;`

## Remarks:
This is false for a new mixer or sound, and is turned on by the first call to `set_position_3d()`. Turning it off makes the mixer heard as though it was at the listener's position, without changing its position, so turning it on again restores it.
