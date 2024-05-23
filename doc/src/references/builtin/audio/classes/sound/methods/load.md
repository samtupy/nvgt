# load
Loads a sound file with the specified settings.

1. `bool sound::load(string filename, pack@ soundpack = null, bool allow_preloads = true);`
2. `bool sound::load(sound_close_callback@ close_cb, sound_length_callback@ length_cb, sound_read_callback@ read_cb, sound_seek_callback@ seek_cb, string data, string preload_filename = "");`

## Arguments (1):
* string filename: the name/path to the file that is to be loaded.
* pack@ soundpack = null: a handle to the pack object to load this sound from, if any.
* bool allow_preloads = true: whether or not the sound system should preload sounds into memory on game load.

## Arguments (2):
* sound_close_callback@ close_cb: the close callback to use with the sound (see remarks).
* sound_length_callback@ length_cb: the length callback to use with the sound (see remarks).
* sound_read_callback@ read_cb: the read callback to use with the sound (see remarks).
* sound_seek_callback@ seek_cb: the seek callback to use with the sound (see remarks).
* string data: the audio data of the sound.
* string preload_filename = "": the name of the file to be preloaded (if any).

## Returns:
bool: true if the sound was successfully loaded, false otherwise.

## Remarks:
The syntax for the sound_close_callback is:
> void sound_close_callback(string user_data);

The syntax for the sound_length_callback is:
> uint sound_length_callback(string user_data);

The syntax for the sound_read_callback is:
> int sound_read_callback(string &out buffer, uint length, string user_data);

The syntax for the sound_seek_callback is:
> bool sound_seek_callback(uint offset, string user_data);
