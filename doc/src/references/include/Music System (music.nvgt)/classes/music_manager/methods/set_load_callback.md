# set_load_callback
This system was originally made for Survive the Wild which needs to read sound data from strings not packs most of the time, so this class implements something more complicated than a music.pack variable being set. Someone feel free to add this functionality though or I may do later. Instead, we set a callback which receives a sound object and a filename, and calls the appropriate load method on that sound for your situation. Not needed if your sounds are simply on disk. A short example of a load callback is below.

`void music_manager::set_load_callback(load_music_sound@ cb);`

## Arguments:
* load_music_sound@ cb: your load callback. The syntax of it is `sound@ load_music_sound(sound@ sound_to_load, string filename_to_load);`. See remarks for an example.

## Remarks:
This is a basic example of how to write and set up a sound loading callback for use with the music manager.

```
sound@ music_load(sound@ sound_to_load, string filename_to_load) {
	// Usually a sound object will be provided to this function from the music manager. Encase not,
	if (@sound_to_load is null) @sound_to_load = sound();
	if( !sound_to_load.load(filename_to_load, pack_file)) return null; // indicates error.
	return s; // Return a handle to the loaded sound.
}

// ...

your_music_manager.set_load_callback(music_load);
```
