# audio_splitter_node
A node that sends the audio it receives to two outputs, so that it can be processed in two different ways at once.

`audio_splitter_node(audio_engine@ engine, int channels);`

## Arguments:
* audio_engine@ engine: the engine to create the node in.
* int channels: the number of channels of the audio, usually the engine's `channels`.

## Remarks:
This is an audio_node with one input bus and two output buses, and has all of the methods and properties of audio_node. Both output buses carry a copy of the input, and their volumes can be set independently with `set_output_bus_volume()`.

A typical use is sending a sound both straight to the speakers and to an effect such as a reverb, which is how `reverb3d::create_attachment()` works.
