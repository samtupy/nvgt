# play_1d
Play a sound in 1 dimension and return a slot.

`int sound_pool::play_1d(string filename, pack@ packfile, float listener_x, float sound_x, bool looping, bool persistent = false);`

## Arguments:
* string filename: the file to play.
* pack@ packfile: the pack to use. This can be omitted.
* float listener_x: the listener coordinates in X form.
* float sound_x: the coordinates of the sound in X form.
* bool looping: should the sound play continuously?
* bool persistent = false: should the sound be cleaned up once the sound is finished playing?

## Returns:
int: the index of the sound which can be modified later, or -1 if error. This method may return -2 if the sound is out of earshot.

## Remarks:
If the looping parameter is set to true and the sound object is inactive, the sound is still considered to be active as this just means that we are currently out of earshot. A non-looping sound that has finished playing is considered to be dead, and will be cleaned up if it is not set to be persistent.
