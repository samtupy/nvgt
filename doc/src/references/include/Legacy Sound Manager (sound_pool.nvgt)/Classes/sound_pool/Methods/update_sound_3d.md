# update_sound_3d
Updates the sound coordinate in 3 dimensions.

1. `bool sound_pool::update_sound_3d(int slot, int x, int y, int z);`
2. `bool sound_pool::update_sound_3d(int slot, vector coordinate);`

## Arguments (1):
* int slot: the slot of the sound you wish to update.
* int x: the X coordinate of the sound.
* int y: the Y coordinate of the sound.
* int z: the Z coordinate of the sound.

## Arguments (2):
* int slot: the slot of the sound you wish to update.
* vector coordinate: the coordinate of the sound in vector form.

## Returns:
bool: true if the sound is updated successfully, false otherwise.
