# set_listener_enabled
Enable or disable a listener.

`void audio_engine::set_listener_enabled(int index, bool enabled);`

## Arguments:
* int index: the number of the listener, starting at 0. Engines have one listener by default.
* bool enabled: whether sounds are heard from this listener.

## Remarks:
Sounds are heard from the closest enabled listener.
