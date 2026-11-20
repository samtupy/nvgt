# audio_node
An audio_node is one piece of the graph that audio flows through on its way to your speakers. Sounds, mixers, effects such as filters and reverbs, decoders, and the audio_engine that all of them end at are audio nodes. Each node has some input buses, which receive audio from other nodes, and some output buses, which send the audio it produces to the input of another node, and you can change what the nodes in the graph are connected to at any time.

This is the base class of everything that takes part in the graph. Every class in this documentation described as a node, such as sound, mixer and audio_engine, contains all of the methods and properties listed here, which are not documented again for each of them, and can be cast to a plain audio_node handle to pass it to anything that accepts one, such as `attach_output_bus()`. A handle to an audio_node can be cast back to the class it is the base of with `cast<>`.

An audio_node cannot be created directly, you create a sound, an effect or another node that is one.

## Remarks:
### Buses
A bus is a connection point that carries audio with a fixed number of channels. Most nodes have one input bus and one output bus, but some have none of one kind: a sound has no inputs because it produces audio from a file. `input_bus_count` and `output_bus_count` tell you how many a node has, and `get_input_channels()` and `get_output_channels()` how many channels each carries.

An output bus is connected to the input bus of another node with `attach_output_bus()`. Several outputs can be attached to the same input bus, in which case they are mixed together, but an output bus can only be attached to one input at a time. Attaching it again moves it. Connections are kept alive by their output, so a node you attached something to stays alive while it is attached, even if you no longer hold a handle to it.

Sounds and mixers are attached to the audio engine's endpoint automatically, so nothing needs to be done to hear them. You use these methods to put an effect between a sound and the speakers, or to send a sound through several effects, in which case it is easier to use an audio_node_chain.

### States and time
A node is either started or stopped, which you can change with `set_state()`. A stopped node produces no audio and doesn't process its input. The state can also be scheduled to change at a future time with `set_state_time()`.

Times given to and returned from the methods of a node are in PCM frames, where a frame is one sample for each channel, so that 44100 of them are a second at a sample rate of 44100 hertz. They are measured on a global clock that the audio engine runs, which goes forward as audio is produced. Each node also has its own local clock, which `time` reads and `set_time()` changes, that counts the frames the node has processed. The audio_engine is the exception, whose `time` is its global clock, measured in milliseconds unless the AUDIO_ENGINE_DURATIONS_IN_FRAMES flag was used.

## Example:
```
void main() {
	// Send a sound through a low pass filter instead of straight to the speakers.
	sound s;
	s.load("music.ogg");
	audio_low_pass_filter filter(1000, 2); // Remove frequencies above 1000 hertz.
	s.set_mixer(null); // Detach it from its default connection to the engine.
	s.attach_output_bus(0, filter, 0); // The sound's output goes to the filter's input.
	filter.attach_output_bus(0, sound_default_engine.endpoint, 0); // And the filter's goes to the speakers.
	s.play_looped();
	wait(5000);
}
```
