# Music System
This is an include that allows you to easily control music in your game. It can play anything from a stinger to a full music track, control looping, automatic playing, etc.

## Loading music from other sources
Note that I originally made this system for Survive the Wild which needs to read sound data from strings not packs most of the time, so my needs required something more complicated than a music.pack variable being set. Someone feel free to add this functionality though or I may do later. Instead, we set a callback which receives a sound object and a filename, and calls the appropriate load method on that sound for your situation. Not needed if your sounds are simply on disk. A short example of a load callback is below.

```
sound@ music_load(sound@ sound_to_load, string filename_to_load) {
	// Usually a sound object will be provided to this function from the music manager. Encase not,
	if (@sound_to_load is null) @sound_to_load = sound();
	if( !sound_to_load.load(filename_to_load, pack_file)) return null; // indicates error.
	return s; // Return a handle to the loaded sound.
}
music.set_load_callback(music_load);
```
