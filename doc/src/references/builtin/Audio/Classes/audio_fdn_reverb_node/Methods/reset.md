# reset
Silence the reverb immediately, clearing its tail.

`void audio_fdn_reverb_node::reset();`

## Remarks:
This is useful when the listener moves somewhere completely different, such as through a door into another level, and the reverb of the old place shouldn't be heard in the new one.
