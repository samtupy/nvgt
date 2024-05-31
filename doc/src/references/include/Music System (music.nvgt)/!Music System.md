music_manager music;
// play a track
music.play("track.ogg");
// play a stinger at -15 volume and 110% pitch starting at 0.2s into the file which fades in
music.play("stinger.mp3; stinger; p=110; v=-15; f=35; startpos=0.2");
// or play a track with an intro, like crazy party
music.play("main_track.opus; intro=intro.opus");
// if you have a track that doesn't loop, play a new copy of it overtop the currently playing one 3.6 seconds before it ends instead of looping
music.play("notlooped.wav; r=3.2");
// then to let the music manager know when to switch tracks or begin fades and the like, in your loops just
music.loop(ticks()); // Hopefully I can remove the need for this step later
// and if the user presses the volume down key?
music.volume=music.volume-1;
// you can check if a track is currently playing
if(music.playing) // uh, idk?
// this works too
music.set_fx("lowpass:7000:0:0.7");

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
