# play_2d
Play a sound in 2 dimensions and return a slot.

1. `int sound_pool::play_2d(string filename, pack@ packfile, float listener_x, float listener_y, float sound_x, float sound_y, bool looping, bool persistent = false);`
2. `int sound_pool::play_2d(string filename, pack@ packfile, float listener_x, float listener_y, float sound_x, float sound_y, double rotation, bool looping, bool persistent = false);`
3. `int sound_pool::play_2d(string filename, float listener_x, float listener_y, float sound_x, float sound_y, bool looping, bool persistent = false);`
4. `int sound_pool::play_2d(string filename, float listener_x, float listener_y, float sound_x, float sound_y, double rotation, bool looping, bool persistent = false);`

## Arguments:
* string filename: the file to play.
* pack@ packfile: the pack to use (optional).
* float listener_x, listener_y: the listener coordinates in X, Y form.
* float sound_x, sound_y: the coordinates of the sound in X, Y form.
* double rotation: the listener's rotation (optional).
* bool looping: should the sound play continuously?
* bool persistent = false: should the sound be cleaned up once the sound is finished playing?

## Returns:
int: the index of the sound which can be modified later, or -1 if error. This method may return -2 if the sound is out of earshot.

## Remarks:
If the looping parameter is set to true and the sound object is inactive, the sound is still considered to be active as this just means that we are currently out of earshot. A non-looping sound that has finished playing is considered to be dead, and will be cleaned up if it is not set to be persistent.
