# audio_node_state
This is a list of the states that an audio_node can be in, used with `audio_node::set_state()`, `audio_node::get_state()` and the other state functions of nodes.

* AUDIO_NODE_STATE_STARTED: the node is processing audio and passing it on. This is the state nodes begin in.
* AUDIO_NODE_STATE_STOPPED: the node is not processing audio, and produces silence.
