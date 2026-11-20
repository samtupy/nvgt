# audio_engine
An audio_engine is what mixes and plays sounds. It owns the audio device that sound comes out of (unless it was told not to), runs the graph of sounds, mixers and effects that is connected to it, and keeps the listeners that 3D sounds are heard from.

Most programs never create one. NVGT makes a default engine the first time sound is used, which `sound_default_engine` refers to, and every sound, mixer and other audio object you create without naming an engine belongs to it. You only need your own audio_engine to do something the default one can't, such as rendering audio to memory instead of to speakers, or playing to a second device.

`audio_engine@ audio_engine(int flags, int sample_rate = 0, int channels = 0);`

## Arguments:
* int flags: a combination of values from the `audio_engine_flags` enum, or 0 for none.
* int sample_rate = 0: the sample rate in hertz that the engine mixes at. If 0, a rate of 48000 is used for an engine without a device and the rate of the audio device otherwise.
* int channels = 0: the number of output channels, such as 2 for stereo. If 0, 2 is used.

## Remarks:
An exception is thrown if the engine could not be created, or if more channels than are supported are requested.

Unlike the default engine, an engine you create has its attributes work in the engine's natural units, with volume as a linear value where 1 is full volume, rather than the decibels and percentages that the default engine uses for backwards compatibility. Pass AUDIO_ENGINE_PERCENTAGE_ATTRIBUTES to get those too. See the `audio_engine_flags` enum.

The audio_engine is itself an audio_node, so it can be cast to one and contains all of the methods and properties of the audio_node class, such as `input_bus_count`, `attach_output_bus()` and `set_state()`, which are documented there and not repeated here. Sounds and mixers are connected to the engine's `endpoint` node, where the audio goes on to the device.

### Listeners
3D sounds are positioned relative to a listener, which is the position and direction that you are hearing the world from. Most games have a single listener, number 0, whose position and direction you should update as the player moves with `set_listener_position()` and `set_listener_direction()`. A new engine's listener is at the origin, facing along the positive y axis with z up, which is NVGT's usual coordinate system.

### Rendering without a device
An engine created with AUDIO_ENGINE_NO_DEVICE does not play anything, and instead produces audio when you call `read()`. This is useful for encoding audio to a file, for applying effects to sounds offline and for testing.

## Example:
```
void main() {
	// An engine that renders into memory rather than playing.
	audio_engine engine(AUDIO_ENGINE_NO_DEVICE, 44100, 2);
	sound@ s = engine.sound();
	s.load("music.ogg");
	s.play();
	float[]@ samples = engine.read(44100); // One second of audio, interleaved left and right.
	alert("Rendered", samples.length() + " samples were rendered.");
}
```
