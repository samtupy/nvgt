# update_sound_range_3d
Updates the sound range in 3 dimensions.

`bool sound_pool::update_sound_range_3d(int slot, int left_range, int right_range, int backward_range, int forward_range, int lower_range, int upper_range, bool update_sound = true);`

## Arguments:
* int slot: the slot of the sound you wish to update.
* int left_range: the left range to update.
* int right_range: the right range to update.
* int backward_range: the backward range to update.
* int forward_range: the forward range to update.
* int lower_range: the bottom / lower range to update.
* int upper_range: the above / upper range to update.
* bool update_sound = true: toggles whether all the sound will be updated automatically.

## Returns:
bool: true if the sound is updated successfully, false otherwise.
