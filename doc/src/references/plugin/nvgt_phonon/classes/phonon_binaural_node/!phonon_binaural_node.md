# phonon_binaural_node
An audio node that positions its input sound in a direction around the listener using Steam Audio's HRTF. Unlike the HRTF panner used automatically for positioned sounds, the direction is not worked out from the positions of a sound and the listener, you set it yourself, which allows an HRTF to be applied to something that isn't positioned in the world, such as a sound being mixed with other nodes, or a one-off cinematic effect or navigation beacon etc.

`phonon_binaural_node@ phonon_binaural_node(audio_engine@ engine, int channels, int sample_rate, int frame_size = 0);`

## Arguments:
* audio_engine@ engine: the engine the node belongs to.
* int channels: the number of channels of input, either 1 or 2. Stereo input is downmixed in the same way a mono input is positioned.
* int sample_rate: the sample rate of the audio passing through the node, normally that of the engine.
* int frame_size = 0: the number of frames Steam Audio processes at once, or 0 for the default.

## Remarks:
An exception is thrown if channels is not 1 or 2, or if Steam Audio could not be initialized.

The node has 1 input bus and 1 output bus, accessible with the `node` property (or by passing the object where an audio_node is expected), and should be connected between a sound and the engine's endpoint with the attach_output_bus method of audio nodes. Its output is always stereo, with the left and right channels in the engine's first 2 channels.

## Example:
```
void main() {
	phonon_binaural_node binaural(sound_default_engine, 2, 44100);
	sound s;
	s.load("music.ogg");
	s.set_mixer(null);
	s.attach_output_bus(0, binaural, 0);
	binaural.node.attach_output_bus(0, sound_default_engine.endpoint, 0);
	binaural.set_direction(1, 0, 0, 10); // To the right.
	s.play_looped();
	wait(5000);
}
```
