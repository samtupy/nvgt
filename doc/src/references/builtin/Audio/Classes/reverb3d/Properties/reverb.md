# reverb
The reverb effect that sounds are sent through.

`audio_node@ reverb3d::reverb;`

## Remarks:
Setting this swaps the effect while keeping every sound that is sent to the reverb3d attached, which can be used to change the sound of a space, such as when the player walks from a hall into a small room. The new effect's output goes to the reverb3d's `mixer`.
