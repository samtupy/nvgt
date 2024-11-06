# play_3d
Play a sound in 3 dimensions and return a slot.

1. `int sound_pool::play_3d(string filename, pack@ packfile, float listener_x, float listener_y, float listener_z, float sound_x, float sound_y, float sound_z, double rotation, bool looping, bool persistent = false);`
2. `int sound_pool::play_3d(string filename, pack@ packfile, vector listener, vector sound_coordinate, double rotation, bool looping, bool persistent = false);`

## Arguments (1):
* string filename: the file to play.
* pack@ packfile: the pack to use. This can be omitted
* float listener_x, listener_y, listener_z: the listener coordinates in X, Y, Z form.
* float sound_x, sound_y, sound_z: the coordinates of the sound in X, Y, Z form.
* double rotation: the listener's rotation.
* bool looping: should the sound play continuously?
* bool persistent = false: should the sound be cleaned up once the sound is finished playing?

## Arguments (2):
* string filename: the file to play.
* pack@ packfile: the pack to use. This can be omitted
* vector listener: the coordinates of listener in vector form.
* vector sound_coordinate: the coordinates of the sound in vector form.
* double rotation: the listener's rotation.
* bool looping: should the sound play continuously?
* bool persistent = false: should the sound be cleaned up once the sound is finished playing?

## Returns:
int: the index of the sound which can be modified later, or -1 if error. This method may return -2 if the sound is out of earshot.

## Remarks:
If the looping parameter is set to true and the sound object is inactive, the sound is still considered to be active as this just means that we are currently out of earshot. A non-looping sound that has finished playing is considered to be dead, and will be cleaned up if it is not set to be persistent.
