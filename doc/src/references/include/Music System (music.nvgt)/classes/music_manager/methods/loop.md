# loop
Updates the state of the music manager. This has to be called in your main loop, probably with the value of `ticks()` passed to it.

`void music_manager::loop(uint64 t);`

## Arguments:
* uint64 t: the current tick count (you can most likely just make this parameter `ticks()`).
