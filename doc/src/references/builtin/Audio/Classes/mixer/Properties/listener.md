# listener
The index of the listener that the mixer is heard from.

`const uint mixer::listener;`

## Remarks:
This is the pinned listener if `pinned_listener` has been set, and otherwise the listener closest to the mixer. Most games only have listener 0.
