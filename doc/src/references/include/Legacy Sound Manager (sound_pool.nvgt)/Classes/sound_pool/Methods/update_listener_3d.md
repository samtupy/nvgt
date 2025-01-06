# update_listener_3d
Updates the listener coordinate in 3 dimensions.

1. `void sound_pool::update_listener_3d(float listener_x, float listener_y, float listener_z, double rotation = 0.0, bool refresh_y_is_elevation = true);`
2. `void sound_pool::update_listener_3d(vector listener, double rotation = 0.0, bool refresh_y_is_elevation = true);`

## Arguments (1):
* float listener_x: the X coordinate of the listener.
* float listener_y: the Y coordinate of the listener.
* float listener_z: the Z coordinate of the listener.
* double rotation = 0.0: the rotation to use.
* bool refresh_y_is_elevation = true: toggles whether `y_is_elevation` property should refresh from the `sound_pool_default_y_is_elevation` global property.

## Arguments (2):
* vector listener: the coordinates of the listener in vector form.
* double rotation = 0.0: the rotation to use.
* bool refresh_y_is_elevation = true: toggles whether `y_is_elevation` property should refresh from the `sound_pool_default_y_is_elevation` global property.
