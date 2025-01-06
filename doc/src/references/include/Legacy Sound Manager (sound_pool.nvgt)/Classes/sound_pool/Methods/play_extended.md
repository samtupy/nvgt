# play_extended
Play a sound and return a slot. This method has many parameters that can be customized.

`int sound_pool::play_extended(int dimension, string filename, pack@ packfile, float listener_x, float listener_y, float listener_z, float sound_x, float sound_y, float sound_z, double rotation, int left_range, int right_range, int backward_range, int forward_range, int lower_range, int upper_range, bool looping, double offset, float start_pan, float start_volume, float start_pitch, bool persistent = false, mixer@ mix = null, string[]@ fx = null, bool start_playing = true, double theta = 0);`

## Arguments:
* int dimension: the number of dimension to play on, 1, 2, 3.
* string filename: the file to play.
* pack@ packfile: the pack to use.
* float listener_x, listener_y, listener_z: the listener coordinates in X, Y, Z form.
* float sound_x, sound_y, sound_z: the coordinates of the sound in X, Y, Z form.
* double rotation: the listener's rotation.
* int left_range, right_range, backward_range, forward_range, lower_range, upper_range: the range of the sound.
* bool looping: should the sound play continuously?
* double offset: the number of milliseconds for the sound to start playing at.
* float start_pan: the pan of the sound. -100 is left, 0 is middle, and 100 is right.
* float start_volume: the volume of the sound. 0 is maximum and -100 is silent.
* float start_pitch: the pitch of the sound.
* bool persistent = false: should the sound be cleaned up once the sound is finished playing?
* mixer@ mix = null: the mixer to attach to this sound.
* string[]@ fx = null: array of effects to be set.
* bool start_playing = true: should the sound play the moment this function is executed?
* double theta = 0: the theta calculated by `calculate_theta` function in rotation.nvgt include.

## Returns:
int: the index of the sound which can be modified later, or -1 if error. This method may return -2 if the sound is out of earshot.

## Remarks:
If the looping parameter is set to true and the sound object is inactive, the sound is still considered to be active as this just means that we are currently out of earshot. A non-looping sound that has finished playing is considered to be dead, and will be cleaned up if it is not set to be persistent.
