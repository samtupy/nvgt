# sound_is_active
Determine whether the sound is active.

`bool sound_pool::sound_is_active(int slot);`

## Arguments:
* int slot: the sound slot you wish to check.

## Returns:
bool: true if the sound is active, false otherwise.

## Remarks:
If the looping parameter is set to true and the sound object is inactive, the sound is still considered to be active as this just means that we are currently out of earshot. A non-looping sound that has finished playing is considered to be dead, and will be cleaned up.
