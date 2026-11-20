# audio_data_source
The base class of the things that audio can be read from: audio_decoder, audio_ring_buffer and microphone.

## Remarks:
An audio_data_source is an audio_node with no input and one output bus, and has all of the methods and properties of audio_node as well as the ones listed here, which every kind of data source shares. It can't be created directly, create one of the kinds of source instead.

A source can be used in two ways. Attaching its output to another node, or giving it to `sound::open()`, lets the audio engine play it. Calling `read()` instead hands its audio to the script as an array of samples, such as for analysing it or encoding it, and detaches it from the engine.

The `datasource` property of a sound gives the source that the sound is playing from, through which details such as loop points can be set. While a sound is using a source, change its position with the sound's `seek()` rather than the source's, and don't read from it, see `sound::datasource` for why.
