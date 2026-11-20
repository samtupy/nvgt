# time
The node's local clock, in PCM frames.

`const uint64 audio_node::time;`

## Remarks:
This counts the frames the node has processed, and can be set with `set_time()`. For the audio_engine it is instead the engine's global clock, in milliseconds unless the AUDIO_ENGINE_DURATIONS_IN_FRAMES flag is set.
