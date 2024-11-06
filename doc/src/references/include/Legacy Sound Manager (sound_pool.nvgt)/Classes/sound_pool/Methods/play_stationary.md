# play_stationary
Play a sound without using dimension and return a slot.

1. `int sound_pool::play_stationary(string filename, bool looping, bool persistent = false);`
2. `int sound_pool::play_stationary(string filename, pack@ packfile, bool looping, bool persistent = false);`

## Arguments (1):
* string filename: the file to play.
* bool looping: should the sound play continuously?
* bool persistent = false: should the sound be cleaned up once the sound is finished playing?

## Arguments (2):
* string filename: the file to play.
* pack@ packfile: the pack to use.
* bool looping: should the sound play continuously?
* bool persistent = false: should the sound be cleaned up once the sound is finished playing?

## Returns:
int: the index of the sound which can be modified later, or -1 if error. This method may return -2 if the sound is out of earshot.

## Remarks:
If the looping parameter is set to true and the sound object is inactive, the sound is still considered to be active as this just means that we are currently out of earshot. A non-looping sound that has finished playing is considered to be dead, and will be cleaned up if it is not set to be persistent.
