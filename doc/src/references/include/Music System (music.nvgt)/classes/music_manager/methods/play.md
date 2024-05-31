# play
Play a music track with particular parameters.

`bool music_manager::play(string track);`

## Parameters:
* string track: the music track to play, including any options (see remarks for more information about option syntax).

## Returns:
bool: true if the track was able to start playing, false otherwise.

## Remarks:
Music tracks are specified using a very simple string format ("filename; flag; flag; option1=value; option2=value; flag; option3=value...").

Options are deliminated by "; " excluding quotes. The only required setting is the track's main filename, which must be the first option provided. It does not matter in what order any other options or flags are set, the only rule is that the track's configuration string must start with it's main filename.

The difference between a flag and an option is that a flag is usually just a simple switch E. "stinger; ", while an option usually consists of a key/value pair e. "startpos=2.9"

When deeling with fades, values are usually in milliseconds, while when deeling with track durations they are usually specified in float seconds E. 4.555 for 4555 milliseconds.

### List of possible options:
* stinger; disables looping
* loop; causes the track to loop the main file
* repeat_intro; If this, intro, and repeat are specified, causes the intro track to play again at the repeat point rather than the main track
* instaplay; If a track is previously playing, causes this one to instantly begin playing instead of the default behavior of fading out and delaying the playback of this track (see switch_predelay and switch_f below), this sets those 2 variables to 0.
* f=ms; causes the track to fade in at first play, ms=number of milliseconds the fade should take to complete
* p=pitch; Sets the pitch of this track, defaults to 100. If this track streams from the internet, make sure not to set this too high as this could result in playing more of the sound than has been downloaded.
* v=volume; sets the starting volume for this entire track (0=full -100=silent)
* intro=filename; causes the audio file specified here to play before the main track file. By default the main track will begin playing immediatly after the intro track ends unless intro_end is specified.
* repeat=s; How many seconds before the end of the main track should the track repeat again? s=number of seconds (can include milliseconds like 4.681). When the track repeats, it will play overtop the remainder of the currently ending track. repeat=0 is the same as the loop flag, repeat=anything<0 is the same as stinger. If multiple of repeat, loop, stinger are specified, only the one specified last will take effect.
* repeat_f=ms; If repeat is specified and is greater than 0, this option causes the end of the currently playing track to fade out as the repeated track begins to play, and specifies how many ms that fade should take to complete.
* predelay=s; how many seconds (can include milliseconds) before the track should begin after it starts playing?
* switch_predelay=s; Same as above, but only applies if a track was previously playing and the music system switches to this one. Defaults to 300. This and predelay are added together, but this variable is handled by the music manager instead of by this music track unlike predelay.
* switch_f=ms; If the music system is playing a track and then switches to this one, how many milliseconds should it take for the previously playing track to fade out? Defaults to 400.
* intro_end=s; if intro is specified but the audio track specified by intro does not seemlessly transition into the main track, how many seconds (can include milliseconds) before the intro ends should the main track begin playing? The main track will not interrupt the remainder of the intro but will play overtop of it if this option is specified.
* startpos=s; How many seconds (can include milliseconds) into either the intro track if specified else the main track should the audio begin playing E. seek?
