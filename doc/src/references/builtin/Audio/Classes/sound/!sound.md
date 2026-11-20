# sound
A sound plays audio from a file, from memory or from a stream, and is what most games use to make noise.

`sound();`

## Remarks:
The sound class is derived from mixer, which is in turn derived from audio_node. Everything that controls how a sound is heard, such as `volume`, `pitch`, `play()`, `stop()`, `set_position_3d()`, `hrtf` and `effects_chain`, is documented in the mixer class and works the same way on a sound, with only the differences noted there. The methods and properties listed here are the ones that only make sense for a sound, such as loading audio, pausing and seeking.

A sound created with `sound()` belongs to the default audio engine and goes into `sound_default_mixer` if one is set, use `audio_engine::sound()` to create one in another engine. Load audio into it with `load()` or one of the other loading methods, and then play it.

In a game where several sounds come from the same object, such as a character's footsteps and voice, put them into a mixer for that object and position the mixer rather than each sound, which is cheaper and moves all of them together. See the remarks of the mixer class.
