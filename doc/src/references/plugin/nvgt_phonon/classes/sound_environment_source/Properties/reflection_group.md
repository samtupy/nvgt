# reflection_group
The index of the reflection group this sound is currently assigned to, or -1 if it has none.

`const int reflection_group;`

## Remarks:
A sound without a group of its own is heard with the listener's reverb attenuated if the environment's `use_listener_reverb` is enabled. Groups are numbered from 0 up to the environment's `max_sources` and sounds near each other are likely to be in the same group. You will probably rarely have to touch this property on your own unless you are trying to debug performance bottlenecks.
